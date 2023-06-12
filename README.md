## Usage

* 1、 Initialize by `ScreenAdapter`.

```dart
void main() {
  ScreenAdapter.runApp(
    const MyApp(),
    designWidth: 400,
  );
}
```

or

```dart
void main() {
  ScreenAdapter.ensureInitialized(designWidth: 400);
  ScreenAdapter.runApp(const MyApp());
}
```

* 2、Transform `MediaQueryData` by `ScreenAdapter`.

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
    // over here !!!
    builder: ScreenAdapter.compatBuilder,
  );
}
```

or

```dart
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
    // over here !!!
    builder: (context, child) => MediaQuery(
      data: ScreenAdapter.compatMediaQueryData(context),
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
```
