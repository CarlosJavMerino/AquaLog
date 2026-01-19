class GearSearchResult {
  final String title;
  final String snippet; 
  final String? imageUrl;
  final String link;

  GearSearchResult({
    required this.title,
    required this.snippet,
    this.imageUrl,
    required this.link,
  });

  /// Factory method to parse Google Custom Search API JSON response.
  factory GearSearchResult.fromJson(Map<String, dynamic> json) {
    String? img;

    // Attempt to extract the thumbnail image from the 'pagemap' metadata.
    // Google API structure: pagemap -> cse_image -> [list] -> src
    if (json['pagemap'] != null && json['pagemap']['cse_image'] != null) {
      final List images = json['pagemap']['cse_image'];
      if (images.isNotEmpty) {
        img = images[0]['src'];
      }
    }

    return GearSearchResult(
      title: json['title'] ?? '',
      snippet: json['snippet'] ?? '',
      link: json['link'] ?? '',
      imageUrl: img,
    );
  }
}