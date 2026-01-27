const mongoose=require("mongoose");

const user_schema=mongoose.Schema({
    username:{
        type:String,
        required:true,
        unique:true
    },
    password:{
        type:String,
        required:true,
        unique:true
    }
})

const user_model=mongoose.model("UserModel",user_schema);

module.exports={user_model}