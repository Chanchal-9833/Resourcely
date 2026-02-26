const express=require("express");
const { signup } = require("../Controller/SignupController");
const { signin } = require("../Controller/SigninController");
const { send_otp, verify_otp } = require("../Controller/SigninViaOtpController");
const { send_otp_slot, verify_otp_slot } = require("../Controller/Slot_Otp");

const user_routes=express.Router();

user_routes.post("/signup",signup)
user_routes.post("/signin",signin)
user_routes.post("/send-otp",send_otp),
user_routes.post("/verify-otp",verify_otp)
user_routes.post("/send-slot-otp",send_otp_slot)
user_routes.post("/verify-slot-otp",verify_otp_slot)

module.exports={user_routes}

