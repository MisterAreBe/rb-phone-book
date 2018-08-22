document.addEventListener('DOMContentLoaded', function() {
    updateForm(document.querySelector('#mah_form'));
});
window.onload = function() {
    var y = document.getElementById("yScroll");
    window.scrollTo(0, y.value);
}
function updateForm(theForm) {
    theForm.addEventListener('blur', function(evt) {
        var x = evt.target;
        console.log(evt);
        var xId = x.id;
        console.log(xId);
        var xValue = x.value;
        console.log(xValue);
        var y = document.getElementById("rowCol");
        var z = document.getElementById("update");
        y.value = xId;
        z.value = xValue;
        if (y.value.length >= 3) {
            var a = document.getElementById("yScroll");
            var b = window.pageYOffset;
            a.value = b;
            document.getElementById("mah_form").submit();
        }
    }, true);
}

function format(phone) {
    var p_val = phone.value.replace(/\D[^\.]/g, "");
    phone.value = p_val.slice(0,3)+"-"+p_val.slice(3,6)+"-"+p_val.slice(6);
    return phone.value;
}

function openModal() {
    document.getElementById("modal").style.display = "inline-block";
}

function closeModal() {
    document.getElementById("modal").style.display = "none";
}

window.onclick = function(event) {
    var modal = document.getElementById("modal");
    if (event.target == modal) {
        document.getElementById("modal").style.display = "none";
    }
}

function clearFound() {
    document.getElementById("stop_search").value = "clear";
    document.getElementById("search_item").value = "";
    search();
}

function search() {
    z = document.getElementById("stop_search");
    var name = document.getElementById("search_form").elements["search_item"].value;
    var pattern = name.toLowerCase();
    var td = document.getElementsByClassName("name_phone");
    var contact, table, index;
        if (z.value == "clear") {
            for (var x = 0; x < td.length; x++) {
                contact = td[x].getElementsByTagName("input");
                table = contact[0].parentNode.parentNode.parentNode.parentNode;
                table.style.backgroundColor = "#e4e70fc4";
                contact[0].style.borderBottom = "none";
            }
            z.value = "";
        }else if (pattern.length > 1) {
        for (var i = 0; i < td.length; i++) {
            contact = td[i].getElementsByTagName("input");
            index = contact[0].value.toLowerCase();
            if (pattern == index) {
                table = contact[0].parentNode.parentNode.parentNode.parentNode;
                table.scrollIntoView();
                table.style.backgroundColor = "green";
                contact[0].style.borderBottom = "1px solid white";
            }
        }
    }
}