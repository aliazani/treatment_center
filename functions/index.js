// functions/index.js
// FIXED Firebase Cloud Function for sending emails with attachments

const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const axios = require("axios");

admin.initializeApp();

/**
 * Creates email transporter with runtime configuration
 * FIXED: Changed createTransporter to createTransport
 * @return {Object} The nodemailer transporter
 */
function createEmailTransporter() {
  return nodemailer.createTransport({ // FIXED: was createTransporter
    service: "gmail", // or your email service
    auth: {
      user: functions.config().email.user,
      pass: functions.config().email.password,
    },
  });
}

/**
 * Sends assessment email with attachments via Cloud Functions
 * @param {Object} data - The request data
 * @param {Object} context - The function context
 * @return {Promise<Object>} The response object
 */
exports.sendAssessmentEmail = functions.https.onCall(async (data, context) => {
  // Add detailed logging
  console.log("📧 Email function called with data:",
      JSON.stringify(data, null, 2));
  console.log("🔐 Auth context:",
    context.auth ? "authenticated" : "not authenticated");

  try {
    // Validate input data
    const {
      recipientEmail,
      subject,
      body,
      attachmentUrls,
      assessmentData,
    } = data;

    console.log("📋 Validating input parameters...");

    if (!recipientEmail || !subject || !body ||
        !Array.isArray(attachmentUrls)) {
      console.error("❌ Validation failed - missing required fields");
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Missing required fields: recipientEmail, subject, body, or " +
          "attachmentUrls",
      );
    }

    console.log("✅ Input validation passed");
    console.log(`📧 Recipient: ${recipientEmail}`);
    console.log(`📎 Attachments: ${attachmentUrls.length}`);

    // Download attachments from Firebase Storage URLs
    console.log("📥 Downloading attachments...");
    const attachments = await Promise.all(
        attachmentUrls.map(async (url, index) => {
          try {
            console.log(`📥 Downloading attachment ${index + 1}: ${url}`);
            const response = await axios.get(url,
                {responseType: "arraybuffer"});
            const fileName = extractFileNameFromUrl(url) ||
                `attachment_${index + 1}`;

            console.log(`✅ Downloaded: ${fileName} 
              (${response.data.length} bytes)`);

            return {
              filename: fileName,
              content: Buffer.from(response.data),
              contentType: response.headers["content-type"] ||
                  "application/octet-stream",
            };
          } catch (error) {
            console.error(`❌ Failed to download attachment from ${url}:`
                , error);
            throw new functions.https.HttpsError(
                "internal",
                `Failed to download attachment: ${error.message}`,
            );
          }
        }),
    );

    console.log(`✅ Successfully downloaded ${attachments.length} attachments`);

    // Prepare email options
    const mailOptions = {
      from: functions.config().email.from || functions.config().email.user,
      to: recipientEmail,
      subject: subject,
      html: formatEmailBodyAsHtml(body, assessmentData),
      text: body,
      attachments: attachments,
    };

    console.log("📧 Preparing to send email...");
    console.log(`From: ${mailOptions.from}`);
    console.log(`To: ${mailOptions.to}`);
    console.log(`Subject: ${mailOptions.subject}`);

    // Create email transporter with runtime config
    const transporter = createEmailTransporter();

    // Test the connection first
    console.log("🔗 Testing SMTP connection...");
    try {
      await transporter.verify();
      console.log("✅ SMTP connection verified");
    } catch (smtpError) {
      console.error("❌ SMTP connection failed:", smtpError);
      throw new functions.https.HttpsError(
          "internal",
          `SMTP connection failed: ${smtpError.message}`,
      );
    }

    // Send email
    console.log("📤 Sending email...");
    const info = await transporter.sendMail(mailOptions);
    console.log("✅ Email sent successfully:", info.messageId);

    // FIXED: More robust Firestore logging with error handling
    try {
      console.log("📝 Logging email to Firestore...");
      const emailLogData = {
        recipientEmail,
        subject,
        attachmentCount: attachments.length,
        assessmentId: assessmentData && assessmentData.id ?
            assessmentData.id : null,
        facilityName: assessmentData && assessmentData.facilityName ?
            assessmentData.facilityName : null,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        messageId: info.messageId,
        status: "sent",
      };

      await admin.firestore().collection("email_logs").add(emailLogData);
      console.log("✅ Email logged to Firestore successfully");
    } catch (firestoreError) {
      console.error("⚠️ Failed to log to Firestore (non-critical):"
          , firestoreError);
      // Don't throw error here - email was sent successfully
    }

    console.log("🎉 Email process completed successfully");

    return {
      success: true,
      messageId: info.messageId,
      attachmentCount: attachments.length,
    };
  } catch (error) {
    console.error("❌ Detailed error in email function:", {
      message: error.message,
      stack: error.stack,
      code: error.code,
      type: error.constructor.name,
    });

    // FIXED: More robust error logging
    try {
      await admin.firestore().collection("email_logs").add({
        recipientEmail: data.recipientEmail || "unknown",
        subject: data.subject || "unknown",
        error: error.message,
        errorCode: error.code || "unknown",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: "failed",
      });
    } catch (logError) {
      console.error("⚠️ Failed to log error to Firestore:", logError);
    }

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
        "internal",
        `Failed to send email: ${error.message}`,
    );
  }
});

/**
 * Helper function to extract filename from Firebase Storage URL
 * @param {string} url - The Firebase Storage URL
 * @return {string|null} The extracted filename or null
 */
function extractFileNameFromUrl(url) {
  try {
    const urlObj = new URL(url);
    const pathParts = urlObj.pathname.split("/");

    // Firebase Storage URLs typically have the filename as the last part
    // before the token
    for (let i = pathParts.length - 1; i >= 0; i--) {
      const part = pathParts[i];
      if (part && part.includes(".")) {
        return decodeURIComponent(part);
      }
    }

    return null;
  } catch (error) {
    console.error("Error extracting filename from URL:", error);
    return null;
  }
}

/**
 * Helper function to format email body as HTML
 * @param {string} body - The plain text body
 * @param {Object} assessmentData - The assessment data object
 * @return {string} The formatted HTML body
 */
function formatEmailBodyAsHtml(body, assessmentData) {
  const htmlBody = body.replace(/\n/g, "<br>");

  if (!assessmentData) {
    return htmlBody;
  }

  return `
    <div style="font-family: Arial, sans-serif; max-width: 600px; ` +
    `margin: 0 auto;">
      <div style="background-color: #f8f9fa; padding: 20px; ` +
    `border-radius: 8px;">
        <h2 style="color: #333; margin-bottom: 20px;">FVD Treatment ` +
    `Center Assessment</h2>
        
        <div style="background-color: white; padding: 15px; ` +
    `border-radius: 5px; margin-bottom: 20px;">
          <h3 style="color: #495057; margin-top: 0;">Assessment ` +
    `Summary</h3>
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 8px 0; font-weight: bold; ` +
    `color: #6c757d;">Facility:</td>
              <td style="padding: 8px 0;">` +
    `${assessmentData.facilityName || "N/A"}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; ` +
    `color: #6c757d;">Code:</td>
              <td style="padding: 8px 0;">` +
    `${assessmentData.facilityCode || "N/A"}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; ` +
    `color: #6c757d;">Location:</td>
              <td style="padding: 8px 0;">` +
    `${assessmentData.location || "N/A"}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; ` +
    `color: #6c757d;">Assessor:</td>
              <td style="padding: 8px 0;">` +
    `${assessmentData.assessorName || "N/A"}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; ` +
    `color: #6c757d;">Completion:</td>
              <td style="padding: 8px 0;">` +
    `${assessmentData.completionPercentage || 0}%</td>
            </tr>
          </table>
        </div>
        
        <div style="background-color: white; padding: 15px; ` +
    `border-radius: 5px;">
          ${htmlBody}
        </div>
        
        <div style="margin-top: 20px; padding: 10px; ` +
    `background-color: #e9ecef; border-radius: 5px; font-size: 12px; ` +
    `color: #6c757d;">
          <p style="margin: 0;">This email was sent automatically from ` +
    `the FVD Treatment Center Assessment System.</p>
          <p style="margin: 5px 0 0 0;">Assessment ID: ` +
    `${assessmentData.id || "N/A"}</p>
        </div>
      </div>
    </div>
  `;
}

/**
 * Additional function for batch email sending (if needed)
 * @param {Object} data - The request data
 * @param {Object} context - The function context
 * @return {Promise<Object>} The response object
 */
exports.sendBatchAssessmentEmails = functions.https.onCall(
    async (data, context) => {
      try {
        const {emailRequests} = data;

        if (!Array.isArray(emailRequests)) {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "emailRequests must be an array",
          );
        }

        const results = await Promise.allSettled(
            emailRequests.map(async (request) => {
              return await exports.sendAssessmentEmail.handler(
                  request,
                  context,
              );
            }),
        );

        const successful = results.filter((r) => r.status === "fulfilled")
            .length;
        const failed = results.filter((r) => r.status === "rejected").length;

        return {
          success: true,
          totalRequests: emailRequests.length,
          successful,
          failed,
          results: results.map((r) => ({
            status: r.status,
            value: r.status === "fulfilled" ? r.value : null,
            error: r.status === "rejected" ? r.reason.message : null,
          })),
        };
      } catch (error) {
        console.error("Error in batch email sending:", error);
        throw new functions.https.HttpsError(
            "internal",
            `Failed to send batch emails: ${error.message}`,
        );
      }
    },
);

/**
 * Function to clean up old attachments from Firebase Storage
 * @param {Object} context - The function context
 * @return {Promise<Object>} The response object
 */
exports.cleanupOldAttachments = functions.pubsub.schedule("0 2 * * *")
    .onRun(async (context) => {
      try {
        const storage = admin.storage();
        const bucket = storage.bucket();

        // Delete files older than 30 days
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

        const [files] = await bucket.getFiles({
          prefix: "assessments/",
        });

        let deletedCount = 0;

        for (const file of files) {
          const [metadata] = await file.getMetadata();
          const timeCreated = new Date(metadata.timeCreated);

          if (timeCreated < thirtyDaysAgo) {
            await file.delete();
            deletedCount++;
          }
        }

        console.log(`Cleaned up ${deletedCount} old attachment files`);
        return {deletedCount};
      } catch (error) {
        console.error("Error cleaning up old attachments:", error);
        throw error;
      }
    });
