import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String _cloudName = 'dpvmprkx8';
  static const String _uploadPreset = 'blok34_uploads';

  Future<String> uploadImage(
      File imageFile, {
        required String folder,
      }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.fields['upload_preset'] = _uploadPreset;

    request.fields['folder'] = folder;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final response = await request.send();

    print("STATUS: ${response.statusCode}");
    print("BODY: $response");

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Image upload failed (${response.statusCode})',
      );
    }

    final responseBody =
    await response.stream.bytesToString();

    final data = jsonDecode(responseBody);

    return data['secure_url'];
  }
}