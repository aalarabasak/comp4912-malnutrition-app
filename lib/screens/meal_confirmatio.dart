import 'package:flutter/material.dart';
import 'dart:io';

class MealConfirmationUnpackaged extends StatelessWidget {
  final File image;          // Çekilen fotoğraf
  final Map<String, dynamic> foodData; // API'den gelen veri (isim, güven, kutu vb.)

  const MealConfirmationUnpackaged({
    Key? key, 
    required this.image, 
    required this.foodData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // API'den gelen isim (Örn: "burger")
    String foodName = foodData['class'] ?? "Bilinmiyor";
    double confidence = foodData['confidence'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text("Yemek Onayı")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Çekilen Fotoğraf
            Image.file(
              image,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Başlık ve Güven Oranı
                  Text(
                    "Algılanan Yemek:",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    foodName.toUpperCase(), // Örn: BANANA
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  Text(
                    "Güven Oranı: %${(confidence * 100).toStringAsFixed(1)}",
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),

                  Divider(height: 40, thickness: 1.5),

                  // 3. Besin Değerleri (RAD Tasarımı - Placeholder Veriler)
                  Text("Besin Değerleri (Tahmini)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  _buildNutrientRow("Enerji", "105 kcal"),
                  _buildNutrientRow("Protein", "1.3 g"),
                  _buildNutrientRow("Karbonhidrat", "27 g"),
                  _buildNutrientRow("Yağ", "0.3 g"),

                  SizedBox(height: 30),

                  // 4. Kaydet ve İptal Butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("İptal"),
                          style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15)),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Kaydetme işlemi buraya gelecek
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Yemek Kaydedildi! ✅"))
                            );
                            Navigator.pop(context); // Ana sayfaya dön
                            Navigator.pop(context); // Popup'ı da kapatmış oluyoruz
                          },
                          child: Text("Kaydet"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, 
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15)
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Besin değeri satırı için yardımcı widget
  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[800])),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}