import 'package:ChatBot/base.dart';

class PromptAddPage extends ConsumerStatefulWidget {
  const PromptAddPage({super.key});

  @override
  ConsumerState createState() => _PromptAddPageState();
}

class _PromptAddPageState extends ConsumerState<PromptAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Author',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Prompt',
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Hint',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Add Prompt
              },
              child: Text('Add Prompt'),
            ),
          ],
        ),
      ),
    );
  }
}
