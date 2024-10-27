#!/bin/bash

# Function to update the VPS
update_vps() {
    echo "Updating the VPS..."
    sudo apt update && sudo apt upgrade -y
    echo "VPS update complete."
}

# Check if Node.js is installed
check_node() {
    if ! command -v node &> /dev/null; then
        echo "Node.js is not installed. Please install Node.js first."
        exit 1
    fi
}

# Check if npm is installed
check_npm() {
    if ! command -v npm &> /dev/null; then
        echo "npm is not installed. Please install npm first."
        exit 1
    fi
}

# Create a package.json file if it doesn't exist
create_package_json() {
    if [ ! -f package.json ]; then
        echo "Creating package.json file..."
        npm init -y
    fi
}

# Install required libraries
install_dependencies() {
    echo "Installing required libraries..."
    npm install axios cheerio fs
}

# Create the video collection script file
create_script_file() {
    cat << 'EOF' > collectVideos.js
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
EOF
}

# Main script execution
update_vps
check_node
check_npm
create_package_json
install_dependencies
create_script_file

echo "Setup complete. You can edit collectVideos.js to update the login URL, target URL, and credentials."
