const mongoose = require("mongoose");
const { user_model } = require("../Models/UserModel");
const bcryptjs=require("bcryptjs")

const signup = async (req, res, next) => {
  const { username, password } = req.body;

  try {
    if (!username || !password) {
      return next({
        statuscode: 404,
        message: " Credentials are Required.",
      });
    }

    const b_password=bcryptjs.hashSync(password,10)
    const user_reg=await user_model({
        username:username,
        password:b_password
    })
    await user_reg.save()

    res.status(200).json({
        status:1,
        success:true,
        message:"User Has Signed Up SuccessFully."
    })

  } catch (err) {
    return next(err);
  }
};

module.exports={signup}