function noob() {
    var userLabel = document.getElementById("userNameLabel");
    var user = document.getElementById("userName");
    var passLabel = document.getElementById("passLabel");
    var pass = document.getElementById("pass");
    var vPassLabel = document.getElementById("vPassLabel");
    var vPass = document.getElementById("vPass");
    var cancel = document.getElementById("cancel");
    var newUser = document.getElementById("newUser");
    var login = document.getElementById("loginUser");
    var create = document.getElementById("createUser");
    var form = document.getElementById("da_form");

    form.action = "/new_user";
    login.type = "hidden";
    create.type = "submit";
    newUser.type = "hidden";
    cancel.type = "button";
    vPass.type = "password";
    vPassLabel.style.display = "inline-block";
    userLabel.innerText = "New Username:";
    user.placeholder = "New Username";
    passLabel.innerText = "New Password:";
    pass.placeholder = "New Password";
}
function nevermind() {
    var userLabel = document.getElementById("userNameLabel");
    var user = document.getElementById("userName");
    var passLabel = document.getElementById("passLabel");
    var pass = document.getElementById("pass");
    var vPassLabel = document.getElementById("vPassLabel");
    var vPass = document.getElementById("vPass");
    var cancel = document.getElementById("cancel");
    var newUser = document.getElementById("newUser");
    var login = document.getElementById("loginUser");
    var create = document.getElementById("createUser");
    var form = document.getElementById("da_form");

    form.action = "/login";
    login.type = "submit";
    create.type = "hidden";
    newUser.type = "button";
    cancel.type = "hidden";
    vPass.type = "hidden";
    vPassLabel.style.display = "none";
    userLabel.innerText = "Username:";
    user.placeholder = "Username";
    passLabel.innerText = "Password:";
    pass.placeholder = "Password";
}