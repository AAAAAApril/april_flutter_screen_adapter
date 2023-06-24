## Usage

* 1、 Initialize by `ScreenAdapter`.

```dart
void main() {
  // over here !!!
  ScreenAdapter.ensureInitialized(designWidth: 400);
  runApp(const MyApp());
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
