require("dotenv").config();
const express = require("express");
const { google } = require("googleapis");
const bodyParser = require("body-parser");

const app = express();
app.use(bodyParser.json());

// Initialize OAuth2 client
const oauth2Client = new google.auth.OAuth2(
	process.env.GOOGLE_FIT_CLIENT_ID,
	process.env.GOOGLE_FIT_CLIENT_SECRET,
	process.env.GOOGLE_FIT_REDIRECT_URI
);

// Scopes for Google Fit API
const SCOPES = [
	"https://www.googleapis.com/auth/fitness.activity.read",
	"https://www.googleapis.com/auth/fitness.blood_glucose.read",
	"https://www.googleapis.com/auth/fitness.blood_pressure.read",
	"https://www.googleapis.com/auth/fitness.heart_rate.read",
	"https://www.googleapis.com/auth/fitness.body.read",
	"https://www.googleapis.com/auth/fitness.sleep.read",
	"https://www.googleapis.com/auth/userinfo.profile",
];

// Generate Auth URL
app.get("/auth", (req, res) => {
	const authUrl = oauth2Client.generateAuthUrl({
		access_type: "offline",
		scope: SCOPES,
	});
	res.redirect(authUrl);
});

// Handle OAuth2 Callback
app.get("/oauth2callback", async (req, res) => {
	const code = req.query.code;
	if (!code) return res.status(400).send("Authorization code missing");

	try {
		const { tokens } = await oauth2Client.getToken(code);
		oauth2Client.setCredentials(tokens);
		res.json({
			message: "Authorization successful",
			tokens,
		});
		// res.redirect("/fitness-data");
	} catch (error) {
		console.error("Error during token exchange:", error);
		res.status(500).send("Failed to exchange token");
	}
});

// Fetch Fitness Data
app.get("/fitness-data", async (req, res) => {
	try {
		const fourteenDaysInMillis = 14 * 24 * 60 * 60 * 1000;
		const startTimeMillis = Date.now() - fourteenDaysInMillis;
		const endTimeMillis = Date.now() + 24 * 60 * 60 * 1000;

		const fitness = google.fitness({ version: "v1", auth: oauth2Client });
		const response = await fitness.users.dataset.aggregate({
			userId: "me",
			requestBody: {
				aggregateBy: [
					{ dataTypeName: "com.google.step_count.delta" },
					{ dataTypeName: "com.google.blood_glucose" },
					{ dataTypeName: "com.google.blood_pressure" },
					{ dataTypeName: "com.google.heart_rate.bpm" },
					{ dataTypeName: "com.google.weight" },
					{ dataTypeName: "com.google.height" },
					{ dataTypeName: "com.google.sleep.segment" },
				],
				bucketByTime: { durationMillis: 86400000 },
				startTimeMillis,
				endTimeMillis,
			},
		});

		const fitnessData = response.data.bucket || [];
		const formattedData = fitnessData.map((data) => {
			const formattedDate = new Date(
				parseInt(data.startTimeMillis)
			).toDateString();
			const formattedEntry = {
				date: formattedDate,
				step_count: 0,
				glucose_level: 0,
				blood_pressure: [],
				heart_rate: 0,
				weight: 0,
				height_in_cms: 0,
				sleep_hours: 0,
			};

			data.dataset.forEach((dataset) => {
				const point = dataset.point;
				if (point && point.length > 0) {
					const value = point[0]?.value || [];
					switch (dataset.dataSourceId) {
						case "derived:com.google.step_count.delta:com.google.android.gms:aggregated":
							formattedEntry.step_count = value[0]?.intVal || 0;
							break;
						case "derived:com.google.blood_glucose.summary:com.google.android.gms:aggregated":
							formattedEntry.glucose_level =
								value.reduce((acc, v) => acc + (v.fpVal || 0), 0) * 10;
							break;
						case "derived:com.google.blood_pressure.summary:com.google.android.gms:aggregated":
							const bloodPressure = value
								.map((v) => v.fpVal)
								.sort((a, b) => b - a);
							formattedEntry.blood_pressure =
								bloodPressure.length === 2 ? bloodPressure : [0, 0];
							break;
						case "derived:com.google.heart_rate.summary:com.google.android.gms:aggregated":
							formattedEntry.heart_rate = value.reduce(
								(acc, v) => acc + (v.fpVal || 0),
								0
							);
							break;
						case "derived:com.google.weight.summary:com.google.android.gms:aggregated":
							formattedEntry.weight = value[0]?.fpVal || 0;
							break;
						case "derived:com.google.height.summary:com.google.android.gms:aggregated":
							formattedEntry.height_in_cms = (value[0]?.fpVal || 0) * 100;
							break;
						case "derived:com.google.sleep.segment:com.google.android.gms:merged":
							formattedEntry.sleep_hours = value[0]?.fpVal || 0;
							break;
					}
				}
			});

			return formattedEntry;
		});

		// **Important: Send response**
		res.json(formattedData);
	} catch (error) {
		console.error("Error fetching fitness data:", error);
		res.status(500).json({ error: "Failed to fetch fitness data" });
	}
});

// Refresh Token
app.post("/refresh-token", async (req, res) => {
	const { refreshToken } = req.body;
	if (!refreshToken) {
		return res.status(400).json({ error: "Missing refresh token" });
	}

	try {
		// Refresh the access token
		const { credentials } = await oauth2Client.refreshToken(refreshToken);

		// Send the new tokens to the client
		res.json({
			access_token: credentials.access_token,
			expires_in: credentials.expiry_date,
			refresh_token: credentials.refresh_token || refreshToken, // Keep old refresh token if no new one
		});
	} catch (error) {
		console.error("Error refreshing token:", error);
		res.status(500).json({ error: "Failed to refresh token" });
	}
});

// Token code
oauth2Client.setCredentials({
	access_token:
		"ya29.a0AXeO80QpiwFeLGXLh7xuq5kgWJpahqXBRqJt-eE4M8VlLa9vGizG73LAi6qu_VVUiEE8u_z3ZrXnWz7biCQ4GXUhuksgZQVmWTktUypG8sdaF4xO_AC2uy7-ZvgQRrz-dLbrPoUJfCPnL2iiegy2gV9zRQQPzDK3KAaCgYKAWYSARISFQHGX2MiNGua4yxcg225JPD-N3zaIQ0169",
	refresh_token: "YOUR_REFRESH_TOKEN",
});

// Function to ensure fresh access token
async function getAccessToken() {
	try {
		const { credentials } = await oauth2Client.refreshToken(
			oauth2Client.credentials.refresh_token
		);
		oauth2Client.setCredentials(credentials);
		console.log("✅ Access Token Refreshed");
		return credentials.access_token;
	} catch (error) {
		console.error("❌ Error refreshing access token:", error);
		throw new Error("Failed to refresh access token");
	}
}

// 🔹 Route to fetch Google Fit Data
app.get("/data", async (req, res) => {
	try {
		// Ensure we have a fresh access token
		const accessToken = await getAccessToken();

		// Set up Google Fit API
		const fitness = google.fitness({ version: "v1", auth: oauth2Client });

		const startTimeMillis = Date.now() - 14 * 24 * 60 * 60 * 1000; // 14 days ago
		const endTimeMillis = Date.now() + 24 * 60 * 60 * 1000; // Now

		// Fetch fitness data
		const response = await fitness.users.dataset.aggregate({
			userId: "me",
			requestBody: {
				aggregateBy: [
					{ dataTypeName: "com.google.step_count.delta" },
					{ dataTypeName: "com.google.blood_glucose" },
					{ dataTypeName: "com.google.blood_pressure" },
					{ dataTypeName: "com.google.heart_rate.bpm" },
					{ dataTypeName: "com.google.weight" },
					{ dataTypeName: "com.google.height" },
					{ dataTypeName: "com.google.sleep.segment" },
				],
				bucketByTime: { durationMillis: 86400000 },
				startTimeMillis,
				endTimeMillis,
			},
		});

		// Format Data
		const fitnessData = response.data.bucket.map((data) => {
			const formattedDate = new Date(
				parseInt(data.startTimeMillis)
			).toDateString();
			return {
				date: formattedDate,
				step_count: data.dataset[0]?.point[0]?.value[0]?.intVal || 0,
				glucose_level: data.dataset[1]?.point[0]?.value[0]?.fpVal || 0,
				blood_pressure: data.dataset[2]?.point[0]?.value.map(
					(v) => v.fpVal
				) || [0, 0],
				heart_rate: data.dataset[3]?.point[0]?.value[0]?.fpVal || 0,
				weight: data.dataset[4]?.point[0]?.value[0]?.fpVal || 0,
				height_in_cms: (data.dataset[5]?.point[0]?.value[0]?.fpVal || 0) * 100,
				sleep_hours: data.dataset[6]?.point[0]?.value[0]?.intVal || 0,
			};
		});

		// Send JSON Response
		res.json({ success: true, data: fitnessData });
	} catch (error) {
		console.error("❌ Error fetching fitness data:", error);
		res
			.status(500)
			.json({ success: false, error: "Failed to fetch fitness data" });
	}
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
	console.log(`Server is running on port ${PORT}`);
});

function formatDate() {
	const now = new Date();
	console.log(now);
	const day = String(now.getDate()).padStart(2, "0");
	const month = String(now.getMonth() + 1).padStart(2, "0");
	const year = now.getFullYear();

	return `${day} ${month} ${year}`;
}
