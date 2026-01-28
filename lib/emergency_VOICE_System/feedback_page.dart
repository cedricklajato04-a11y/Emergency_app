import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  int rating = 0; // Customer rating from 1 to 5

  void submitFeedback() {
    if (feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your feedback")),
      );
      return;
    }

    // You can also access rating and commentController.text here
    String message =
        "Feedback submitted!\nRating: $rating stars\nComment: ${commentController.text}";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // Clear all fields
    feedbackController.clear();
    commentController.clear();
    setState(() {
      rating = 0;
    });
  }

  Widget buildStar(int starIndex) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: starIndex <= rating ? Colors.amber : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          rating = starIndex;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 199, 199),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(214, 184, 23, 23),
        title: const Text("Feedback"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "We value your feedback",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tell us about your experience using the Emergency Voice System.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Main Feedback TextField
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Enter your feedback here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // ⭐ Rating
            const Text(
              "Rate our service:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),
            const SizedBox(height: 20),

            // Optional Comment Field
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Add additional comments (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(214, 184, 23, 23),
                ),
                child: const Text(
                  "SUBMIT",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
