const nodemailer=require("nodemailer")
const { otp_model } = require("../Models/OtpModels")
const send_otp=async(req,res,next)=>{

  const {email}=req.body
  if(!email){
    return next({statuscode:404,message:"Email Not Found "})
  }
  const otp = Math.floor(100000 + Math.random() * 900000);
  try{
    let transporter=await nodemailer.createTransport({
        service:"gmail",
        port: 587,
  secure: false, // Use true for port 465, false for port 587
  auth: {
    user: process.env.EMAIL_URL,
    pass: process.env.APP_PASSWORD
  },
    })
         const message = await transporter.sendMail({
   from: `"Resourcely" <${process.env.EMAIL_URL}>`,
   to: email,
   subject: "Resourcely Otp for Signin",
   text: "Resourcely Otp for Signiin", // plain‑text body
   html: `<h2>Your OTP is ${otp}</h2><p>Valid for 120 seconds</p>`, // HTML body
 });
 const otp_save=await otp_model({email:email,otp:otp})
 otp_save.save()
 res
   .status(200)
   .json({
     status: 1,
     success:true,
     msg: "OTP Sent to Mail",
     previewURL: nodemailer.getTestMessageUrl(message),
   });
  }
  catch(err){

    return next(err)

  }

}
const verify_otp=async(req,res,next)=>{
  const {otp,email}=req.body
   if(!otp){
   return next({statuscode:404,message:"Otp Not Found "})
 }
  if(!email){
 return next({statuscode:404,message:"Email Not Found "})
 }

 try{
  const fetch_otp=await otp_model.findOne({otp:otp,email:email})

  if(!fetch_otp){
    return next({statuscode:400,message:"Invalid Otp"})
  }
   await otp_model.deleteOne({ _id: fetch_otp._id });

  res.status(200).json({
    status:1,
    success:true,
    msg:"Otp Verified SuccessFully."
  })



 }
 catch(err){
  next(err)
 }


}
 module.exports={send_otp,verify_otp}