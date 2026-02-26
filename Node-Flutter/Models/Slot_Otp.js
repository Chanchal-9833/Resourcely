const mongoose=require("mongoose")

const slot_otp_schema=mongoose.Schema({
     email: {
    type: String,
    required: true
  },

  pcnumber: {
    type: Number,
    required: true
  },

  bookingDate: {        // 🔥 Store selected booking date
    type: Date,
    required: true
  },

  startTime: {          // 🔥 Store as Date (same day with time)
    type: Date,
    required: true
  },

  endTime: {            // 🔥 Store as Date
    type: Date,
    required: true
  },

  otp: {
    type: String,
    required: true
  },

}, { timestamps: true });


const slot_otp_model=mongoose.model("slot_otp_model",slot_otp_schema)

module.exports={slot_otp_model}