const nodemailer = require("nodemailer");
// const { slot_otp_model } = require("../Models/Slot_Otp");
const moment = require("moment");
const { slot_otp_model } = require("../Models/Slot_Otp");

const send_otp_slot = async (req, res, next) => {

  const { email, pcnumber, bookingDate, startTime, endTime } = req.body;

  if (!email || !pcnumber || !bookingDate || !startTime || !endTime) {
    return next({ statuscode: 400, message: "All booking details required" });
  }

  const otp = Math.floor(100000 + Math.random() * 900000);

  try {

    // ✅ Convert booking date + time into Date objects
    const booking_Date = moment(bookingDate, "YYYY-MM-DD").toDate();

    const start = moment(
      `${bookingDate} ${startTime}`,
      "YYYY-MM-DD hh:mm A"
    ).toDate();

    const end = moment(
      `${bookingDate} ${endTime}`,
      "YYYY-MM-DD hh:mm A"
    ).toDate();

    // Optional: prevent duplicate active OTP for same booking
    await slot_otp_model.deleteMany({
      email,
      pcnumber,
      bookingDate: booking_Date
    });

    // ✅ Save OTP with booking details
    await slot_otp_model.create({
      email,
      pcnumber,
      bookingDate: booking_Date,
      startTime: start,
      endTime: end,
      otp
    });

    // ✅ Send Email
    const transporter = nodemailer.createTransport({
      service: "gmail",
      port: 587,
      secure: false,
      auth: {
        user: process.env.EMAIL_URL,
        pass: process.env.APP_PASSWORD
      },
    });

    await transporter.sendMail({
      from: `"Resourcely" <${process.env.EMAIL_URL}>`,
      to: email,
      subject: "Your Resourcely Booking OTP",
      html: `
        <h2>Your OTP: ${otp}</h2>
        <p><strong>PC Number:</strong> ${pcnumber}</p>
        <p><strong>Date:</strong> ${bookingDate}</p>
        <p><strong>Time:</strong> ${startTime} - ${endTime}</p>
        <p>This OTP will remain valid until your booking ends.</p>
      `,
    });

    return res.status(200).json({
      success: true,
      message: "OTP Sent Successfully"
    });

  } catch (err) {
    next(err);
  }
};
const verify_otp_slot = async (req, res, next) => {

  const { otp, email } = req.body;

  if (!otp || !email) {
    return next({ statuscode: 400, message: "OTP or Email missing" });
  }

  try {

    const fetch_otp = await slot_otp_model.findOne({ otp, email });

    if (!fetch_otp) {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP"
      });
    }

    // 🔥 Check if booking time is already over
    const now = new Date();

    if (now > fetch_otp.endTime) {
      return res.status(400).json({
        success: false,
        message: "Booking time expired. OTP no longer valid."
      });
    }

    // ✅ OTP is valid — delete it
    await slot_otp_model.deleteOne({ _id: fetch_otp._id });

    return res.status(200).json({
      success: true,
      message: "OTP Verified Successfully"
    });

  } catch (err) {
    next(err);
  }
};
module.exports = { send_otp_slot,verify_otp_slot };