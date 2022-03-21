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

export const updateUserEmail = functions.https.onCall(async (data, context)=>{
  const user = data.user;
  const email = data.email;
  await admin.auth().getUser(user).then((userRecord) => {
    functions.logger.info("User Found!", {structuredData: true});
    const uid = userRecord.uid;
    return admin.auth().updateUser(uid, {
      email: email,
    });
  })
      .then(() => {
        functions.logger.info("Email Updated!", {structuredData: true});
      })
      .catch((error) =>{
        functions.logger.info("Error on updating user mail!", error,
            {structuredData: true});
      });
});

export const updateUserPass = functions.https.onCall(async (data, context)=>{
  const user = data.user;
  const password = data.password;
  await admin.auth().getUser(user).then((userRecord) => {
    functions.logger.info("User Found!", {structuredData: true});
    const uid = userRecord.uid;
    return admin.auth().updateUser(uid, {
      password: password,
    });
  })
      .then(() => {
        functions.logger.info("Password Updated!", {structuredData: true});
      })
      .catch((error) =>{
        functions.logger.info("Error on updating user password!", error,
            {structuredData: true});
      });
});

export const shiftNotif = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const message = {
    token: token,
    notification: {
      title: "Vagt tildelt",
      body: "Du er blevet tildelt en vagt. Se i appen for detaljer.",
    },
  };

  admin.messaging().send(message)
      .then(() => {
        functions.logger.info("Message sent", {structuredData: true});
      })
      .catch((error) =>{
        functions.logger.info("Error on sending message", error,
            {structuredData: true});
      });
});


