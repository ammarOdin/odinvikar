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

export const addShiftNotif = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Vagt tildelt",
      body: "Du er blevet tildelt en vagt d. "+date+". Accepter i app'en.",
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

export const editShiftNotif = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Vagt Redigeret",
      body: "Din vagt d. "+date+" er blevet redigeret. Accepter i app'en.",
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

export const acceptShiftNotif = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const name = data.name;
  const message = {
    token: token,
    notification: {
      title: "Vagt Accepteret",
      body: "Vagten d. "+date+" er blevet accepteret af "+name,
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

export const deletedShiftNotif = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Vagt Slettet",
      body: "Vagten d. "+date+" er blevet slettet.",
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

export const acceptShiftSys = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Vagtbanken",
      body: "Dit bud på d. "+date+" er blevet accepteret.",
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

export const shiftOfferNotif = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const name = data.name;
  const message = {
    token: token,
    notification: {
      title: "Bud på vagt",
      body: name+" har budt på vagten d. "+date+".",
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

export const shiftCreated = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Vagtbanken",
      body: "En vagt er blevet oprettet til d. "+date+" i Vagtbanken.",
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

export const acuteShift = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "AKUT VAGT",
      body: "En akut vagt er blevet oprettet til d. "+date+" i Vagtbanken.",
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

export const summonedUser = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Tilkaldt arbejde",
      body: "Du er blevet tilkaldt til arbejde d. "+date,
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

export const cancelledShift = functions.https.onCall(async (data, context)=>{
  const token = data.token;
  const date = data.date;
  const message = {
    token: token,
    notification: {
      title: "Vagt afbooket",
      body: "Din vagt d. "+date+" er blevet afbooket.",
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


