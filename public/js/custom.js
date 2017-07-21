/* ----------------------------------------------- DOCUMENT READY FUNCTIONS ----------------------------------------------- */

function highlightRow(id) {
  $(id).on('change', "input[name='checkbox[]']", function() {
    console.log("FUNCTION");
    if($(this).is(':checked'))
      $(this).parent().siblings().andSelf().css('background-color', '#c2efc2 ');
    else{
      $('.manNote').siblings().andSelf().css('background-color','#ffb3b3');
      $('.manNoteEmpty').siblings().andSelf().css('background-color','');
    }
  });
}

function checkAll(id) {
  console.log("FUNCTION TWO");
  $(id).on("change","input[id='submitSelectAll']", function () {
    if ($(this).prop('checked')) {
      $('input').prop('checked', true);
    }
    else {
      $('input').prop('checked', false);
    }
    if($(this).is(':checked')) {
      $("input[name='checkbox[]']").parent().siblings().andSelf().css('background-color', '#c2efc2 ');
    }
    else{
      $("input[name='checkbox[]']").parent().siblings().andSelf().css('background-color', '');
      $('.manNote').siblings().andSelf().css('background-color','#ffb3b3');
      $('.manNoteEmpty').siblings().andSelf().css('background-color','');
    } 
  });
  $('#submitSelectAll').trigger('change');
}

function hoursentryReset() {
  $('.manNote').siblings().andSelf().css('background-color','#ffb3b3');
  $('.manNoteEmpty').siblings().andSelf().css('background-color','');
}
function formReset() {
  $("input[name='checkbox[]']").parent().siblings().andSelf().css('background-color', '');
}

function toggleNotesColumn(){
  if ($(".normalNote")[0]){
    // Do something if class exists
    $("#normalNoteTh").show();
    $(".normalNoteEmpty").show();
  } else {
    // Do something if class does not exist
    $("#normalNoteTh").hide();
    $(".normalNoteEmpty").hide();
  }
}

function toggleManNotesColumn() {
  if ($(".manNote")[0]){
    // Do something if class exists
    $("#manNoteTh").show();
    $(".manNoteEmpty").show();
  } else {
    // Do something if class does not exist
    $("#manNoteTh").hide();
    $(".manNoteEmpty").hide();
  }
}

function toggleSubgroupColumn() {
  if ($(".subgroup")[0]){
    // Do something if class exists
    $("#subgroupTh").show();
    $(".subgroupEmpty").show();
  } else {
    // Do something if class does not exist
    $("#subgroupTh").hide();
    $(".subgroupEmpty").hide();
  }
}

function toggleSubgroup() {
  /*will apply function when Cgroup change*/
  $('#Cgroup').on('change', function() {
    /*When Cgroup= "Study Tours"*/
    if ( this.value == 'Study Tours'){
      $("#subgroupHeading").show();
      $("#subgroupRow").show();
      $("#subgroupInput").show();
      $("#subgroupReq").prop('required',true);
    }
    else{
      $("#subgroupHeading").hide();
      $("#subgroupRow").hide();
      $("#subgroupInput").hide();
      $("#subgroupReq").prop('required',false);
    }
  });
}

function initialiseDateTimePicker() {
  $('input.datepicker').datepicker({
    dateFormat: "dd/mm/yy"
  });
  $('input.timepicker').timepicker({
    timeFormat: 'h:mm p',
    dynamic: false,
    dropdown: false,
    scrollbar: false
  });
}
/* ----------------------------------------------- END DOCUMENT READY FUNCTIONS ----------------------------------------------- */


// CHANGES DATE FROM YYYY-DD-MM TO DD-MM-YYYY, RETURNS AS STRING
function customDate(dt) {
  var d = dt;
  d = new Date(d);
  var day = String(d.getDate());
  if (day.length < 2)
    day = '0' + day;
  var month = String(d.getMonth() + 1); // Month is from 0-11
  if (month.length < 2)
    month = '0' + month;
  var year = String(d.getFullYear());

  var date = String(day+ '/' + month + '/' +year);
  return date;
}

//CHANGES ALL DISPLAYED DATES WITH CLASS *changeDates* TO DD/MM/YYYY FORMAT
function changeDateTime() {
	var d = document.getElementsByClassName('changeDate');
  for (var i = 0; i < d.length; i++){
    var x = String(d[i].innerHTML)
    d[i].innerHTML = customDate(x);
    d[i].value = d[i].innerHTML;
  }

  var dec = document.getElementsByClassName('decimals');
  for (var i = 0; i < dec.length; i++){
    var x = String(dec[i].innerHTML)
    x = +x;
    x = x.toFixed(2);
    dec[i].innerHTML = x;
  }
}


function openPDF(id) {
  window.open('/pdfSaveAccounts/?id='+id);
}

function TotalHours() {

  var start = $("#startTime").val();
  var end = $("#endTime").val();

  //create date format          
  var timeStart = new Date("01/01/2007 " + start).getTime();
  var timeEnd = new Date("01/01/2007 " + end).getTime();
  var difference = parseFloat((timeEnd - timeStart)/3600000).toFixed(2);  //Milliseconds to hours

  if (difference >= 0) {
    document.getElementById('Hours').value = difference;
    document.getElementById('HourShow').value = difference;
  }
  else{
    //document.getElementById('Hours').value = "";
    document.getElementById('HourShow').value = "Invalid";
  }
}

function count() {

  var inputElems = document.getElementsByName("checkbox[]"),
  count = 0;
  for (var i=0; i<inputElems.length; i++) {
    if (inputElems[i].type === "checkbox" && inputElems[i].checked === true) {
      count++;
    }
  }
  return count;
}

function formValidation() {
  var inputElems = document.querySelectorAll("input[required], select[required]");
  for (var i=0; i<inputElems.length; i++){
    if (inputElems[i].value == null || inputElems[i].value == "" || inputElems[i].value == "N/A"){
      alert("Error: Missing required field(s). \nEnsure all available fields are filled and that hours are not 'invalid' before posting");
      return false;
    }
  }
  return true;
}

function sumHours(name) {
  var h = document.getElementsByClassName(name);
  var sum = 0;
  for (var i = 0; i < h.length; i++){
    sum += parseFloat(h[i].innerHTML);
  }
  return sum.toFixed(2);
}

/* ----------------------------------------------- MODAL RELATED FUNCTIONS ----------------------------------------------- */


function openEdit(id) {
	$('.modal-header-text').text("Do you wish to edit this entry?");
  $("#modalYes").attr("class", "btn btn-success");
  $("#modalYes").attr("form", "editForm");
  $("#modalYes").text("Submit Changes");
  $("#modalNo").text("Cancel");
  $("#modalNo").attr("form", "editForm");
  $("#modalReset").toggle();
  $("#modalReset").attr("form", "editForm");
  $(".modal-body").show();
  $(".modal-content").css('display', 'inherit');
  $(".modal-content").css('max-width', '35%');
  document.getElementById('myModal').style.display='block';
  $(".modal-body").load("/edit/" + id);
  //$("#edit_form").attr("action"); //Will retrieve it
  //$("#edit_form").attr("action", "/edit" + id); //Will set it
}

function openApprove(id) {
  var c = count();
  if (c == 0) {
    $('.modal-header-text').text("Please check boxes for at least one entry in order to approve");
  }
  else if (c == 1) {
    $(".modal-header-text").text("Are you sure you want to ");
    $(".modal-header-text").append("<span style='color:#5bb75b; font-weight: 900'>APPROVE </span>");
    $(".modal-header-text").append("this element?");
  }
  else {
    $(".modal-header-text").text("Are you sure you want to ");
    $(".modal-header-text").append("<span style='color:#5bb75b; font-weight: 900'>APPROVE </span>");
    $(".modal-header-text").append("these ");
    $(".modal-header-text").append("<span style='color:#5bb75b' class='text1'></span>");
    $(".text1").text(c);
    $(".modal-header-text").append(" elements?");
  }

  $(".modal-body").hide();
  $("#modalYes").attr("class", "btn btn-success");
  $("#modalYes").attr("form", "submitapprovals");
  $("#modalYes").text("APPROVE");
  $("#modalNo").text("Cancel");
  $("#modalNo").attr("form", "");
  $("#modalNo").attr("onclick", "modal.style.display = 'none'");
  document.getElementById('myModal').style.display='block';
}

function openDisapprove(id) {
  $(".modal-header-text").text("Are you sure you want to ");
  $(".modal-header-text").append("<span style='color:#da4f49; font-weight: 900'>DISAPPROVE </span>");
  $(".modal-header-text").append("this element?");
  $("#modalYes").attr("class", "btn btn-danger");
  $("#modalYes").attr("form", "disapproveForm");
  $("#modalYes").text("DISAPPROVE");
  $("#modalNo").text("Cancel");
  $("#modalNo").attr("form", "disapproveForm");
  $(".modal-body").show();
  document.getElementById('myModal').style.display='block';
  $(".modal-body").load("/disapprove/" + id);
}

function openSubmit(id) {

	var c = count();
	if (c == 0) {
		$('.modal-header-text').text("Please check boxes for at least one entry in order to submit");
	}
	else if (c == 1) {
  	$(".modal-header-text").text("Are you sure you want to ");
  	$(".modal-header-text").append("<span style='color:#5bb75b; font-weight: 900'>SUBMIT </span>");
  	$(".modal-header-text").append("this element?");
	}
	else {
		$(".modal-header-text").text("Are you sure you want to ");
		$(".modal-header-text").append("<span style='color:#5bb75b; font-weight: 900'>SUBMIT </span>");
		$(".modal-header-text").append("these ");
		$(".modal-header-text").append("<span style='color:#5bb75b' class='text1'></span>");
		$(".text1").text(c);
		$(".modal-header-text").append(" elements?");
	}
	$(".modal-body").hide();
	$("#modalYes").attr("class", "btn btn-success");
  $("#modalYes").attr("form", "submitEntry");
  $("#modalYes").text("SUBMIT");
  $("#modalNo").text("Cancel");
  $("#modalNo").attr("form", "");
  $("#modalNo").attr("onclick", "modal.style.display = 'none'");
  document.getElementById('myModal').style.display='block';
}

function openDelete(id) {
	var c = count();
	if (c == 0 && !id) {
		$('.modal-header-text').text("Please check boxes for at least one entry in order to delete");
	}
	else if (c == 1) {
  	$(".modal-header-text").text("Are you sure you want to ");
  	$(".modal-header-text").append("<span style='color:#da4f49; font-weight: 900'>DELETE </span>");
  	$(".modal-header-text").append("this element?");
    $("#submitEntry").attr("action", "/delete")
    $("#modalYes").attr("form", "submitEntry");
  }
 else if (id) {
    $(".modal-header-text").text("Are you sure you want to ");
    $(".modal-header-text").append("<span style='color:#da4f49; font-weight: 900'>DELETE </span>");
    $(".modal-header-text").append("this element?");
    $("#deleteEntry").attr("action", "/delete")
    $("#modalYes").attr("form", "deleteEntry");
  }
	else {
		$(".modal-header-text").text("Are you sure you want to ");
		$(".modal-header-text").append("<span style='color:#da4f49; font-weight: 900'>DELETE </span>");
		$(".modal-header-text").append("these ");
		$(".modal-header-text").append("<span style='color:#da4f49' class='text1'></span>");
		$(".text1").text(c);
		$(".modal-header-text").append(" elements?");
    $("#submitEntry").attr("action", "/delete")
    $("#modalYes").attr("form", "submitEntry");
	}
	$(".modal-body").hide();
  //$("#submitEntry").attr("action", "/delete")
  //$("#modalYes").attr("form", "submitEntry");
  $("#modalYes").attr("class", "btn btn-danger");
  $("#modalYes").text("DELETE");
  $("#modalNo").text("Cancel");
  $("#modalNo").attr("form", "");

  $("#modalNo").attr("onclick", "modal.style.display = 'none'");
  document.getElementById('myModal').style.display='block';
}

function openEntered(id) {

  var c = count();
  if (c == 0) {
    $('.modal-header-text').text("Please check boxes for at least one entry to mark as entered");
  }
  else if (c == 1) {
    $(".modal-header-text").text("Are you sure you want to mark this element as entered?");
  }
  else {
    $(".modal-header-text").text("Are you sure you want to mark these ");
    $(".modal-header-text").append("<span style='color:#5bb75b' class='text1'></span>");
    $(".text1").text(c);
    $(".modal-header-text").append(" elements as entered?");

  }
  $(".modal-body").hide();
  $("#modalYes").attr("class", "btn btn-success");
  $("#modalYes").attr("form", "enterapprovals");
  $("#modalYes").text("Mark as ENTERED");
  $("#modalNo").text("Cancel");
  $("#modalNo").attr("form", "");
  $("#modalNo").attr("onclick", "modal.style.display = 'none'");
  document.getElementById('myModal').style.display='block';
}

/* ----------------------------------------------- END MODAL RELATED FUNCTIONS ----------------------------------------------- */




/* ----------------------------------------------- TABLE SORTER RELATED FUNCTIONS ----------------------------------------------- */

function initialiseSorter() {
  $.tablesorter.defaults.widgets = ['zebra'];
  $.tablesorter.defaults.theme = 'blue';
  $(".table1").tablesorter({
    sortList: [[2, 1], [4, 1]]
    } );
  $(".table2").tablesorter({
    sortList: [[0, 1], [2, 1]]
    } );
  $(".pending").tablesorter({
    sortList: [[1, 1], [2, 1], [3, 1]]
    } );
  $(".approved").tablesorter({
    sortList: [[0, 1], [1, 1], [2, 1]]
    } );
  $('.table2').tablesorter().tablesorterPager({
    container: $(".pager"),
    output: '{startRow} to {endRow} (of {totalRows})',
    updateArrows: true,
    // fixedHeight: true,
    // css class names of pager arrows
    // next page arrow
    cssNext: '.next',
    // previous page arrow
    cssPrev: '.prev',
    // go to first page arrow
    cssFirst: '.first',
    // go to last page arrow
    cssLast: '.last',
    // location of where the "output" is displayed
    cssPageDisplay: '.pagedisplay',
    // dropdown that sets the "size" option
    cssPageSize: '.pagesize',
    // class added to arrows when at the extremes 
    // (i.e. prev/first arrows are "disabled" when on the first page)
    // Note there is no period "." in front of this class name
    cssDisabled: 'disabled'
  });
}
/* ----------------------------------------------- END TABLE SORTER RELATED FUNCTIONS ----------------------------------------------- */