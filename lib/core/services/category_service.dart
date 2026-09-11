import '../../models/category_model.dart';
import 'model_codec.dart';
import 'service_client.dart';
import 'service_exception.dart';

class CategoryService {
  final ServiceClient client;
  CategoryService(this.client);

  Future<CategoryModel> create(CategoryModel category) =>
      _write('create', category);
  Future<CategoryModel> update(CategoryModel category) =>
      _write('update', category);

  Future<CategoryModel> _write(String operation, CategoryModel category) =>
      serviceCall(
        () async => ModelCodec.category(
          await client.call('categories.$operation', {
            'id': category.id,
            'name': category.name,
            'imageUrl': category.imageUrl,
          }),
        ),
      );

  Future<CategoryModel> get(String id) => serviceCall(
    () async => ModelCodec.category(await client.get('categories', id)),
  );

  Stream<List<CategoryModel>> watchAll() => serviceStream(
    client.firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ModelCodec.category({...doc.data(), 'id': doc.id}))
              .toList(),
        ),
  );

  Future<void> delete(String id) => serviceCall(() async {
    await client.call('categories.delete', {'id': id});
  });
}
