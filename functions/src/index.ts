import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();


export const deleteUser = functions.https.onCall(async (data, context)=>{
  const user = data.user;
  await admin.auth().getUser(user).then((userRecord) => {
    functions.logger.info("User Found!", {structuredData: true});
    const uid = userRecord.uid;
    return admin.auth().deleteUser(uid);
  })
      .then(() => {
        functions.logger.info("User Deleted!", {structuredData: true});
      })
      .catch((error) =>{
        functions.logger.info("Error on deletion!", error,
            {structuredData: true});
      });
});
