const { onUserCreate } = require("firebase-functions/v2/auth");
const { HttpsError } = require("firebase-functions/v2/https");

exports.beforeCreate = onUserCreate((user) => {
    // Check if the user's email is present and ends with your required domain.
    if (!user.data.email || !user.data.email.endsWith("@jnitin.com")) {
        // If it doesn't, throw an error to block the sign-up.
        throw new HttpsError(
            "invalid-argument",
            "Only users with a 'jnitin.com' email address can sign up."
        );
    }
});