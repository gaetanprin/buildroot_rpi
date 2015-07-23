/* Page HTML chargée à 100% */
$( document ).ready(function() {
	/* Récupération de la valeur du cookie */
	var Value_cookie = Cookies.get('COOKIE_MODE');
	if(Value_cookie == null)
	{
		/* Si aucun cookie alors : standart par defaut */
		Value_cookie = "standard";
		Cookies.set('COOKIE_MODE', 'Standard');
	}
	/* Affichage du mode */
	var SPANNameLinux = document.getElementById("NameLinux");
	SPANNameLinux.innerHTML = Value_cookie;
});
	
/* Initialisation des composants */
$(function() {
	// Init menu drop
	$( "#accordion" ).accordion({
		heightStyle: "content"
	});
	// Init progress bar
	$( "#progressbar" ).progressbar({
		value: false
	});
	$( "#progressbarPERFORM" ).progressbar({
		value: false
	});
	// Paramétrage du slider Alpha
	$( "#slider" ).slider({
		value:50,
		min: 1,
		max: 99,
		step: 1,
		slide: function( event, ui ) {
			$( "#amount" ).val( "(" + ui.value + "%)");
		}
	});
	// Affichage du texte par defaut du slider Alpha
	$( "#amount" ).val("(" + $( "#slider" ).slider( "value" ) + "%)");
});

function ChoixMode() {
	/* Affichage de la progress bar */
 	var DIV_progressbar = document.getElementById("progressbar");
	DIV_progressbar.style.visibility = "visible";
	DIV_progressbar.style.height = "20px";
	/* Affichage des textes du décompte */
	var SPAN_WaitProgressTexte1 = document.getElementById("WaitProgressTexte1");
	var SPAN_WaitProgress = document.getElementById("WaitProgress");
	var SPAN_WaitProgressTexte2 = document.getElementById("WaitProgressTexte2");
	SPAN_WaitProgressTexte1.style.visibility = "visible";
	SPAN_WaitProgress.style.visibility = "visible";
	SPAN_WaitProgressTexte2.style.visibility = "visible";
	/* Affectation de la valeur du cookie */
	var CHOIX_standard = document.getElementById("standard");
	var CHOIX_preempt_rt = document.getElementById("preempt_rt");
	if (CHOIX_standard.checked == true) 
	{
		Cookies.set('COOKIE_MODE', 'Standard');
		/* Execution du SH */
		document.getElementById('ID_FRAME').src = "./cgi-bin/standard.sh";
	}
	else if (CHOIX_preempt_rt.checked == true) 
	{ 
		Cookies.set('COOKIE_MODE', 'Preempt RT');
		/* Execution du SH */
		document.getElementById('ID_FRAME').src = "./cgi-bin/preempt_rt.sh"; 
	}
	else
	{
		Cookies.set('COOKIE_MODE', 'Xenomai');
		/* Execution du SH */
		document.getElementById('ID_FRAME').src = "./cgi-bin/xenomai.sh"; 
	}
	/* Affichage des secondes */
	DelayProgressBarTexte();
}

function DelayProgressBarTexte() {
	var DIV_WaitProgress = document.getElementById("WaitProgress");
	DIV_WaitProgress.innerHTML=(parseInt(DIV_WaitProgress.innerHTML)-1);
	if(parseInt(DIV_WaitProgress.innerHTML) >= 1)
	{
		/* Delais d'attente d'une seconde */
		setTimeout('DelayProgressBarTexte()',1000);
	}
	else
	{
		/* Rafraichissement de la page HTML */
		window.location.reload();
	}
}
			
function numKey(evt){
    	var charCode = (evt.which) ? evt.which : event.keyCode
    	if (charCode > 31 && (charCode < 48 || charCode > 57))
	{
		return false;
	}
    	return true;
}
		
function CheckNo(sender){
	// Verification si nombre compris entre 1 et 999
	if(!isNaN(sender.value)){
		if(sender.value > 999 )
	    		sender.value = 999;
		if(sender.value < 1 )
	    		sender.value = 1;
    	}
}

function OutputChange(sender){
	var TexteOutput = document.getElementById("Texte_output");
	var IDmyonoffswitch = document.getElementById("myonoffswitch");
	if(sender.checked == true)
	{
		/* Affichage du texte ON output */
		TexteOutput.innerHTML = "ON";
		/* Check mode choisi */
		if(IDmyonoffswitch.checked == true)
		{
			// Execution du prog C -> Pin OFF debug
			document.getElementById('ID_FRAME').src = "./cgi-bin/test_OFF.sh";
		}
		else
		{
			// Execution du prog C -> Pin ON debug
			document.getElementById('ID_FRAME').src = "./cgi-bin/test_ON.sh";
		}
    	}
	else
	{
		/* Affichage du texte OFF output */
		TexteOutput.innerHTML = "OFF";
		/* Arret du process si il est déjà lancé */
		// Appel du script kill -9 "num du process"
	}
}

function ChoiceChange(sender){
	var DIV_periodic = document.getElementById("periodic");
	var DIV_pulse = document.getElementById("pulse");
	if(sender.checked == true)
	{
		/* Affichage du div periodic */
		DIV_periodic.style.visibility = "hidden";
		DIV_periodic.style.height = "0px";
		DIV_pulse.style.visibility = "visible";
		DIV_pulse.style.height = "auto";
    	}
	else
	{
		/* Affichage du div periodic */
		DIV_periodic.style.visibility = "visible";
		DIV_periodic.style.height = "auto";
		DIV_pulse.style.visibility = "hidden";
		DIV_pulse.style.height = "0px";
	}
}

var dmc_setInterval;

function Perform_mode() {
	/* Affichage de la progress bar */
 	var DIV_progressbar = document.getElementById("progressbarPERFORM");
	DIV_progressbar.style.visibility = "visible";
	DIV_progressbar.style.height = "20px";
	/* Execution du prog C cyclictest */
	var Value_cookie = Cookies.get('COOKIE_MODE');
	if(Value_cookie == "Standard")
	{
		document.getElementById('ID_FRAME').src = "./cgi-bin/test/test_std.sh";
	}
	else if(Value_cookie == "Preempt RT")
	{
		document.getElementById('ID_FRAME').src = "./cgi-bin/test/test_preempt_rt.sh";
	}
	else if(Value_cookie == "Xenomai")
	{
		document.getElementById('ID_FRAME').src = "./cgi-bin/test/test_xenomai.sh";
	}
	/* Delais d'attente : 12 secondes */
	dmc_setInterval = setInterval(Display_IMG_perf, 12000);
}

function Display_IMG_perf() {
	/* Masquage de la progress bar */
	var DIV_progressbar = document.getElementById("progressbarPERFORM");
	DIV_progressbar.style.visibility = "hidden";
	DIV_progressbar.style.height = "0px";
	/* Affichage de l'image */
	document.getElementById('ID_IMG_PERFORM').style.visibility = "visible";
	document.getElementById('ID_IMG_PERFORM').style.height = "250px";
	document.getElementById('ID_IMG_PERFORM').style.width = "400px";
	/* SRC image PNG Performance */
	var Value_cookie = Cookies.get('COOKIE_MODE');
	if(Value_cookie == "Standard")
	{
		/* Affichage image PNG */
		document.getElementById('ID_IMG_PERFORM').src = "test_std.png?random=" + new Date().getTime();
	}
	else if(Value_cookie == "Preempt RT")
	{
		/* Affichage image PNG */
		document.getElementById('ID_IMG_PERFORM').src = "test_preempt_rt.png?random=" + new Date().getTime();
	}
	else if(Value_cookie == "Xenomai")
	{
		/* Affichage image PNG */
		document.getElementById('ID_IMG_PERFORM').src = "test_xenomai.png?random=" + new Date().getTime();
	}
	clearTimeout(dmc_setInterval);
}
