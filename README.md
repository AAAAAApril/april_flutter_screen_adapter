## Usage

* 1、

```dart

void main() {
  ScreenAdapter.ensureInitialized();
  ScreenAdapter.runApp(
    const MyApp(),
    designWidth: 400,
  );
}

```

* 2、

```dart

Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
    builder: ScreenAdapter.compatBuilder,
  );
}

```
