class ListePresence {
  int id = 0;
  String nom = "";
  String prenoms = "";
  String contact = "";

  List<ListePresence> stats = [];

  ListePresence(
      {required this.id,
      required this.nom,
      required this.prenoms,
      required this.contact,
      required this.stats});

  ListePresence.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    prenoms = json['prenoms'];
    contact = json['contact'];

    if (json['stats'] != null) {
      stats.clear();
      json['stats'].forEach((v) {
        stats.add(ListePresence.fromJson(v));
      });
    }
  }
}
