import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

interface SendNotificationData {
  title: string;
  body: string;
  topic?: string;
  data?: Record<string, string>;
}

/**
 * Cloud Function to send push notifications
 * Can send to a specific topic or all users
 */
export const sendNotification = onCall(async (request) => {
  const {title, body, topic, data} = request.data as SendNotificationData;

  if (!title || !body) {
    throw new HttpsError(
      "invalid-argument",
      "Title and body are required"
    );
  }

  const message: admin.messaging.Message = {
    notification: {
      title: title,
      body: body,
    },
    data: data || {},
    topic: topic || "all_users",
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent notification:", response);
    return {success: true, messageId: response};
  } catch (error) {
    console.error("Error sending notification:", error);
    throw new HttpsError("internal", "Failed to send notification");
  }
});

/**
 * Send notification to specific device tokens
 */
export const sendNotificationToDevices = onCall(async (request) => {
  const {title, body, tokens, data} = request.data as {
    title: string;
    body: string;
    tokens: string[];
    data?: Record<string, string>;
  };

  if (!title || !body || !tokens || tokens.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      "Title, body, and tokens are required"
    );
  }

  const message: admin.messaging.MulticastMessage = {
    notification: {
      title: title,
      body: body,
    },
    data: data || {},
    tokens: tokens,
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Successfully sent notifications:", response.successCount);
    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error("Error sending notifications:", error);
    throw new HttpsError("internal", "Failed to send notifications");
  }
});
