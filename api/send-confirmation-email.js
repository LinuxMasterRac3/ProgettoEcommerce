import express from "express";
import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config({ path: ".env.local" });

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    console.log("Received email request:", {
      recipient: req.body.email,
      subject: req.body.subject,
    });

    const { email, subject, message } = req.body;

    if (!email || !subject || !message) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Log SMTP configuration (without passwords)
    console.log("SMTP Configuration:", {
      host: process.env.EMAIL_HOST || "smtp.mailtrap.io",
      port: process.env.EMAIL_PORT || 2525,
      auth: { user: process.env.EMAIL_USER ? "✓ Configured" : "✗ Missing" },
    });

    // Configure transporter with more reliable fallback options
    let transporterConfig;

    if (
      process.env.EMAIL_HOST &&
      process.env.EMAIL_USER &&
      process.env.EMAIL_PASS
    ) {
      // Use configured email service
      transporterConfig = {
        host: process.env.EMAIL_HOST,
        port: process.env.EMAIL_PORT || 587,
        secure: process.env.EMAIL_SECURE === "true",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      };
    } else {
      // Fallback to a test/development service like Mailtrap
      transporterConfig = {
        host: "smtp.mailtrap.io",
        port: 2525,
        auth: {
          user: process.env.MAILTRAP_USER || "your_mailtrap_username",
          pass: process.env.MAILTRAP_PASS || "your_mailtrap_password",
        },
      };
      console.log(
        "Warning: Using fallback email configuration. Set up proper SMTP settings for production."
      );
    }

    const transporter = nodemailer.createTransport(transporterConfig);

    // Verify connection configuration
    transporter.verify(function (error, success) {
      if (error) {
        console.error("SMTP verification failed:", error);
      } else {
        console.log("SMTP server is ready to take our messages");
      }
    });

    // Send email
    const info = await transporter.sendMail({
      from:
        process.env.EMAIL_FROM ||
        '"E-commerce Books" <noreply@ecommerce-books.com>',
      to: email,
      subject: subject,
      html: message,
    });

    console.log("Email sent successfully:", info.messageId);
    res.status(200).json({ success: true, messageId: info.messageId });
  } catch (error) {
    console.error("Error sending email:", error);
    res.status(500).json({
      error: "Failed to send email",
      details: error.message,
      stack: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
});

export default router;
