const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs');

// Replace with the actual login URL and the target URL
const loginUrl = 'https://example.com/login'; // URL for login
const targetUrl = 'https://example.com/protected-page'; // URL to scrape after login

// Your login credentials
const credentials = {
    username: 'your_username', // Replace with your username
    password: 'your_password'   // Replace with your password
};

async function collectVideoLinks() {
    try {
        // Step 1: Log in to the website
        const loginResponse = await axios.post(loginUrl, new URLSearchParams(credentials).toString(), {
            withCredentials: true, // Include cookies for the session
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            }
        });

        // Step 2: Access the protected page
        const response = await axios.get(targetUrl, {
            withCredentials: true, // Include cookies for the session
            headers: {
                'Cookie': loginResponse.headers['set-cookie'].join('; ') // Use the session cookies from the login response
            }
        });

        const html = response.data;
        const $ = cheerio.load(html);

        // Array to store video links
        const videoLinks = [];

        // Step 3: Collect video links
        $('video source').each((i, elem) => {
            const videoSrc = $(elem).attr('src');
            if (videoSrc) {
                videoLinks.push(videoSrc);
            }
        });

        // Select any links with video file extensions
        $('a[href$=".mp4"], a[href$=".mkv"], a[href$=".webm"], a[href$=".m3u8"], a[href$=".mpd"], a[href$=".m3u"]').each((i, elem) => {
            const link = $(elem).attr('href');
            if (link) {
                videoLinks.push(link);
            }
        });

        // Step 4: Save links to a JSON file
        fs.writeFileSync('videoLinks.json', JSON.stringify(videoLinks, null, 2));
        console.log('Video links have been collected and saved to videoLinks.json');
    } catch (error) {
        console.error('Error:', error);
    }
}

// Execute the function
collectVideoLinks();
