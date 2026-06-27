const express=require('express');

const router=express.Router();


const {

createRequest,
getMyRequests,
updateRequest,
deleteRequest

}=require('../controllers/requestController');

const {auth} = require('../middleware/auth');



router.post('/',auth,createRequest);


router.get('/my',auth,getMyRequests);


router.put('/:id',auth,updateRequest);


router.delete('/:id',auth,deleteRequest);



module.exports=router;