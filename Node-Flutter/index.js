const express= require("express");

const app=express();
const dotenv=require("dotenv")
const cors=require("cors")
dotenv.config();

//Mongoose Connection
const mongoose=require("mongoose");
const { user_routes } = require("./Routes/User_Routes");

app.use(cors())
mongoose.connect(process.env.MONGO_DB_URL).then(()=>{
    console.log("Mongoose Connected With Node.Js")
}).catch((err)=>{
    console.log("Monoogse Error, ")
})
app.use(express.json())
//Routes
// test changes


app.use("/user/",user_routes);

//Middleware
app.use((err,req,res,next)=>{
    const statuscode=err.statuscode || 500
    const message=err.message || "Internal Server Error."

    return res.status(statuscode).json({
        status:0,
        success:false,
        message:message,
    })
})
app.listen(process.env.PORT_NUMBER,()=>{
    console.log("Port Running on",process.env.PORT_NUMBER)
})

