document.addEventListener('DOMContentLoaded', function() {
    updateForm(document.querySelector('#mah_form'));
});

function updateForm(theForm) {
    theForm.addEventListener('blur', function(evt) {
        console.log(evt);
        var x = evt.target;
        console.log(x);
        var xId = x.id;
        console.log(xId);
        var xValue = x.value;
        console.log(xValue);
        var y = document.getElementById("rowCol");
        var z = document.getElementById("update");
        y.value = xId;
        z.value = xValue;
        document.getElementById("mah_form").submit();
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