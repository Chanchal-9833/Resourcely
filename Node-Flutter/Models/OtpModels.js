const mongoose=require("mongoose")

const otp_schema=mongoose.Schema({
    email:{
        type:String,
        required:true,
        
    },
    otp:{
        type:String,
        required:true,

    },
    method_type:{
        type:String,
        default:"Signin",
    },
    sent_time:{
        type:Date,
        default:Date.now()
    }
})

const otp_model=mongoose.model("Otp_Model",otp_schema)

module.exports={otp_model}