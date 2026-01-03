/**
 * Visitor Counter Module
 *
 * Fetches and displays visitor count from the API Gateway endpoint.
 * Increments the counter on each page load.
 */

(function() {
    'use strict';

    // API endpoint
    const API_ENDPOINT = 'https://mnsbgvacma.execute-api.us-east-1.amazonaws.com';

    /**
     * Update the visitor count display
     * @param {number} count - The visitor count to display
     */
    function updateCounterDisplay(count) {
        const counterElement = document.getElementById('visitor-count');
        if (counterElement) {
            counterElement.textContent = count.toLocaleString();
        }
    }

    /**
     * Display an error message in the counter
     * @param {string} message - Error message to display
     */
    function displayError(message) {
        const counterElement = document.getElementById('visitor-count');
        if (counterElement) {
            counterElement.textContent = message;
        }
    }

    /**
     * Increment the visitor counter via API
     */
    async function incrementCounter() {
        try {
            // Skip if placeholder (local development)
            if (API_ENDPOINT === 'API_ENDPOINT_PLACEHOLDER') {
                console.log('API endpoint not configured - displaying demo count');
                updateCounterDisplay(42);
                return;
            }

            const response = await fetch(`${API_ENDPOINT}/count`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();
            updateCounterDisplay(data.count);

        } catch (error) {
            console.error('Error incrementing counter:', error);
            displayError('--');
        }
    }

    // Initialize counter when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', incrementCounter);
    } else {
        incrementCounter();
    }
})();
