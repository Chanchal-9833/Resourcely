var admin=require("../firebaseAdmin")
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
   subject: "Your Resourcely Otp is Here.",
   text: "Your Resourcely Otp is Here", // plain‑text body
   html: `<h2>Your OTP is ${otp}</h2>`, // HTML body
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
const verify_otp = async (req, res, next) => {
  const { otp, email } = req.body;

  if (!otp || !email) {
    return next({ statuscode: 400, message: "OTP or Email missing" });
  }

  try {
    // 1️⃣ Verify OTP from DB
    const fetch_otp = await otp_model.findOne({ otp, email });
    if (!fetch_otp) {
      return res.status(400).json({ success: false, message: "Invalid OTP" });
    }

    // 2️⃣ Delete OTP after use
    await otp_model.deleteOne({ _id: fetch_otp._id });

    // 3️⃣ Get or Create Firebase User
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(email);
    } catch (err) {
      userRecord = await admin.auth().createUser({ email });
    }

    // 4️⃣ Create Firebase Custom Token
    const token = await admin.auth().createCustomToken(userRecord.uid);

    // 5️⃣ Send token to Flutter
    return res.status(200).json({
      success: true,
      token: token,
      uid: userRecord.uid,
      email: email,
    });

  } catch (err) {
    next(err);
  }
};


// const verify_otp=async(req,res,next)=>{
  // const {otp,email}=req.body
  //  if(!otp){
  //  return next({statuscode:404,message:"Otp Not Found "})
//  }
  // if(!email){
//  return next({statuscode:404,message:"Email Not Found "})
//  }
// 
//  try{
  // const fetch_otp=await otp_model.findOne({otp:otp,email:email})
// 
  // if(!fetch_otp){
    // return next({statuscode:400,message:"Invalid Otp"})
  // }
  //  await otp_model.deleteOne({ _id: fetch_otp._id });
// 
  // res.status(200).json({
    // status:1,
    // success:true,
    // msg:"Otp Verified SuccessFully."
  // })
// 
// 
// 
//  }
//  catch(err){
  // next(err)
//  }
// 
// 
// }
 module.exports={send_otp,verify_otp}