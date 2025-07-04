// --- Chat Endpoint for Jewelry Questions ---
app.post("/chat-jewelry", async (req, res) => {
  try {
    const { itemId, message, chatHistory, itemDetails } = req.body;

    if (!message || !itemDetails) {
      return res.status(400).json({
        success: false,
        error: "Message and item details are required.",
      });
    }

    // Create context from item details
    const itemContext = `
Jewelry Item Details:
- Type: ${itemDetails.type || "Unknown"}
- Material: ${itemDetails.material || "Unknown"}
- Brand/Maker: ${itemDetails.brandOrMaker || "Unknown"}
- Era/Style: ${itemDetails.eraOrStyle || "Unknown"}
- Authenticity: ${itemDetails.authenticity || "Unknown"}
- Condition: ${itemDetails.condition || "Unknown"}
- Estimated Price: ${itemDetails.estimatedPrice || "Unknown"}
- Description: ${itemDetails.description || "No description available"}
- Gemstones: ${
      itemDetails.gemstoneDetails
        ? JSON.stringify(itemDetails.gemstoneDetails)
        : "None"
    }
- Care Tips: ${itemDetails.careTips || "No care tips available"}
`;

    // Build conversation history
    let conversationHistory = [
      {
        role: "user",
        parts: [
          {
            text: `You are a professional jewelry expert. Here are the details of a jewelry item that a user wants to discuss:\n\n${itemContext}\n\nPlease provide helpful, accurate, and professional advice about this jewelry item. Keep responses concise (2-3 sentences max) and avoid markdown formatting. Use plain text only.`,
          },
        ],
      },
      {
        role: "model",
        parts: [
          {
            text: "I understand. I'm ready to help you with any questions about this jewelry item. I can provide advice on care, value, authenticity, investment potential, and more. What would you like to know?",
          },
        ],
      },
    ];

    // Add chat history if provided
    if (chatHistory && chatHistory.length > 0) {
      conversationHistory = conversationHistory.concat(chatHistory);
    }

    // Add current message
    conversationHistory.push({
      role: "user",
      parts: [{ text: message }],
    });

    // Call Gemini with conversation
    const result = await workoutModel.generateContent({
      contents: conversationHistory,
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 300, // Shorter responses
      },
    });

    const response = result.response;
    const generatedText = response.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!generatedText) {
      return res.status(500).json({
        success: false,
        error: "No response from AI.",
      });
    }

    // Clean up the response to remove markdown and make it more readable
    const cleanedText = generatedText
      .replace(/\*\*(.*?)\*\*/g, "$1") // Remove bold
      .replace(/\*(.*?)\*/g, "$1") // Remove italic
      .replace(/`(.*?)`/g, "$1") // Remove code
      .replace(/^#{1,6}\s+/gm, "") // Remove headers
      .replace(/\[(.*?)\]\(.*?\)/g, "$1") // Remove links
      .replace(/^\s*[-*+]\s+/gm, "• ") // Convert list markers
      .replace(/^\s*\d+\.\s+/gm, "") // Remove numbered lists
      .replace(/\\n/g, "\n") // Fix newlines
      .replace(/\\/g, "") // Remove backslashes
      .trim();

    // Return the response
    res.status(200).json({
      success: true,
      response: cleanedText,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error("Chat error:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// --- Get Chat History Endpoint (Optional) ---
app.get("/chat-history/:itemId", async (req, res) => {
  try {
    const { itemId } = req.params;

    // In a real app, you'd fetch from database
    // For now, return empty array
    res.status(200).json({
      success: true,
      history: [],
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
