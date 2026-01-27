const { user_model } = require("../Models/UserModel");
const bcryptjs=require("bcryptjs")
const jwt=require("jsonwebtoken")
const signin=async(req,res,next)=>{

    const {username,password}=req.body;
    try{
        if(!username || !password){
            return next({statuscode:404,message:"Credentails Not Found"})
        }

        const search_user=await user_model.findOne({username:username})

        // if(search_user==null){
            // return next({statuscode:402,message:"Not Found"})
        // }
        if(!search_user){
            return next({statuscode:404,message:"User Not Found."})
        }

        const b_password=bcryptjs.compareSync(password,search_user.password)

        if(!b_password){
            return next({statuscode:400,message:"Wrong Credentials."})
        }
        const {password:hashed_password,...other}=search_user._doc
        
        const token=jwt.sign({id:search_user._id},process.env.JWT_SECRET_KEY)

        res.status(200).json({
            status:1,
            success:true,
            msg:"User Signed in SuccessFully.",
            data:other,
            token:token    
        })


    }
    catch(err){
        return next(err)
    }
}

module.exports={signin}