
# Asset Management Guide (Flutter)

This guide explains how to organize, add, update, and reference images and other static assets in your Flutter e-commerce app.

## Folder Structure
- `assets/images/products/` — Product images
- `assets/images/categories/` — Category images
- `assets/images/banners/` — Flash sale and promotional banners
- `assets/icons/` — App icons and UI icons
- `assets/fonts/` — Custom fonts (if any)

## Naming Convention
- Use descriptive, consistent names (e.g., `men_shirt_blue.png`, `flash_sale_banner1.png`, `women_handbag_red.webp`).
- Use lowercase and underscores for readability.

## Adding Images
1. Place your image in the appropriate subfolder.
2. Use PNG or WebP format for best quality and performance.
3. Update the manifest table below with the new image path and description.
4. Declare the new asset path in `pubspec.yaml` under `flutter: assets:`:
	 ```yaml
	 flutter:
		 assets:
			 - assets/images/products/
			 - assets/images/categories/
			 - assets/images/banners/
	 ```
5. Run `flutter pub get` to update your project.

## Manifest Example
| Type      | Path                                      | Description                |
|-----------|-------------------------------------------|----------------------------|
| Product   | assets/images/products/men_shirt_blue.png | Men's blue shirt           |
| Category  | assets/images/categories/men.png          | Men's category card        |
| Banner    | assets/images/banners/flash_sale1.png     | Flash sale banner #1       |

## Referencing Images in Flutter
Use the `Image.asset` widget:
```dart
Image.asset('assets/images/products/men_shirt_blue.png', semanticLabel: 'Men Shirt Blue')
```

## Updating Images
- Replace the old image file with the new one using the same name, or update the manifest and code references if the name changes.
- Update `pubspec.yaml` if you add new folders or change asset paths.

## Accessibility & Performance
- Always provide `semanticLabel` for images to support screen readers.
- Use high-contrast images and alt text for accessibility.
- Optimize images for minimal file size and fast loading.
- For network images, use lazy loading and caching (e.g., `CachedNetworkImage`).

## Questions?
Contact the development team for support or refer to the technical documentation for more details.
