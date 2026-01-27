const express=require("express");
const { signup } = require("../Controller/SignupController");
const { signin } = require("../Controller/SigninController");
const { send_otp, verify_otp } = require("../Controller/SigninViaOtpController");

const user_routes=express.Router();

user_routes.post("/signup",signup)
user_routes.post("/signin",signin)
user_routes.post("/send-otp",send_otp),
user_routes.post("/verify-otp",verify_otp)
module.exports={user_routes}

