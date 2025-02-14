// Required Dependencies
const express = require("express");
const axios = require("axios");
const bodyParser = require("body-parser");
const qs = require("qs");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// Fitbit OAuth Configuration
const fitbitConfig = {
	clientId: process.env.FITBIT_CLIENT_ID,
	clientSecret: process.env.FITBIT_CLIENT_SECRET,
	redirectUri: process.env.FITBIT_REDIRECT_URI,
	code_challenge: process.env.FITBIT_CODE_CHALLENGE,
	code_verifier: process.env.FITBIT_CODE_VERIFIER,
	state: process.env.FITBIT_STATE,
	authorizationUrl: "https://www.fitbit.com/oauth2/authorize",
	tokenUrl: "https://api.fitbit.com/oauth2/token",
	apiBaseUrl: "https://api.fitbit.com/1/user/-/",
};

// In-memory store for tokens
let tokens = {
	accessToken: null,
	refreshToken: null,
	expiresIn: null,
	scope: null,
};

// Route: Generate Fitbit Authorization URL
app.get("/auth/fitbit", (req, res) => {
	const scope = "heartrate oxygen_saturation respiratory_rate sleep weight";

	const authUrl = `${
		fitbitConfig.authorizationUrl
	}?response_type=code&client_id=${
		fitbitConfig.clientId
	}&scope=${encodeURIComponent(scope)}&code_challenge=${
		fitbitConfig.code_challenge
	}&code_challenge_method=S256&state=${fitbitConfig.state}`;
	console.log(authUrl);
	res.redirect(authUrl);
});

// Route: Fitbit OAuth Redirect Handler
app.get("/auth/fitbit/callback", async (req, res) => {
	const { code, state } = req.query;

	if (!code || !state) {
		return res.status(400).send("Missing code or state");
	}

	try {
		const response = await axios.post(
			fitbitConfig.tokenUrl,
			qs.stringify({
				client_id: fitbitConfig.clientId,
				grant_type: "authorization_code",
				redirect_uri: fitbitConfig.redirectUri,
				code_verifier: fitbitConfig.code_verifier,
				code,
			}),
			{
				headers: {
					"Content-Type": "application/x-www-form-urlencoded",
					Authorization: `Basic ${Buffer.from(
						`${fitbitConfig.clientId}:${fitbitConfig.clientSecret}`
					).toString("base64")}`,
				},
			}
		);

		tokens = {
			accessToken: response.data.access_token,
			refreshToken: response.data.refresh_token,
			expiresIn: response.data.expires_in,
			scope: response.data.scope,
		};

		res.send("Authorization successful. You can now fetch Fitbit data.");
	} catch (error) {
		console.error("Error exchanging code for tokens:", error.response?.data);
		res.status(500).send("Failed to exchange code for tokens.");
	}
});

// Route: Fetch User Data from Fitbit
app.get("/fitbit/profile", async (req, res) => {
	if (!tokens.accessToken) {
		return res.status(401).send("User is not authenticated.");
	}

	try {
		const response = await axios.get(
			`${fitbitConfig.apiBaseUrl}body/log/weight/date/2025-01-29.json`,
			{
				headers: {
					Authorization: `Bearer ${tokens.accessToken}`,
				},
			}
		);

		res.json(response.data);
	} catch (error) {
		console.error("Error fetching profile data:", error.response?.data);
		if (error.response?.status === 401) {
			res.status(401).send("Access token expired. Please refresh tokens.");
		} else {
			res.status(500).send("Failed to fetch profile data.");
		}
	}
});

// Route: Refresh Access Token
app.post("/auth/fitbit/refresh", async (req, res) => {
	if (!tokens.refreshToken) {
		return res.status(400).send("Refresh token not available.");
	}

	try {
		const response = await axios.post(
			fitbitConfig.tokenUrl,
			qs.stringify({
				grant_type: "refresh_token",
				client_id: fitbitConfig.clientId,
				refresh_token: tokens.refreshToken,
			}),
			{
				headers: {
					"Content-Type": "application/x-www-form-urlencoded",
					Authorization: `Basic ${Buffer.from(
						`${fitbitConfig.clientId}:${fitbitConfig.clientSecret}`
					).toString("base64")}`,
				},
			}
		);

		tokens.accessToken = response.data.access_token;
		tokens.refreshToken = response.data.refresh_token;
		tokens.expiresIn = response.data.expires_in;

		res.send("Access token refreshed successfully.");
	} catch (error) {
		console.error("Error refreshing tokens:", error.response?.data);
		res.status(500).send("Failed to refresh tokens.");
	}
});

// Start Server
app.listen(PORT, () => {
	console.log(`Server running on http://localhost:${PORT}`);
});
