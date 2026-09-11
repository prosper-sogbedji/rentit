import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/item_model.dart';
import 'model_codec.dart';
import 'service_client.dart';
import 'service_exception.dart';

class ItemPage {
  final List<ItemModel> items;
  final DocumentSnapshot<Map<String, dynamic>>? nextCursor;
  const ItemPage({required this.items, required this.nextCursor});
}

class ItemService {
  final ServiceClient client;
  ItemService(this.client);

  /// The explicit hourly rate prevents guessing the meaning of legacy day rates.
  Future<ItemModel> create(ItemModel item, {required int pricePerHourCents}) =>
      _write('create', item, pricePerHourCents);
  Future<ItemModel> update(ItemModel item, {required int pricePerHourCents}) =>
      _write('update', item, pricePerHourCents);

  Future<ItemModel> _write(String operation, ItemModel item, int hourlyCents) =>
      serviceCall(
        () async => ModelCodec.item(
          await client.call('items.$operation', {
            'id': item.id,
            'name': item.name,
            'description': item.description,
            'categoryId': item.categoryId,
            'imageUrl': item.imageUrl,
            'quantity': item.quantity,
            'status': item.status,
            'pricePerHourCents': hourlyCents,
          }),
        ),
      );

  Future<ItemModel> get(String id) =>
      serviceCall(() async => ModelCodec.item(await client.get('items', id)));

  Future<ItemPage> list({
    String? categoryId,
    DocumentSnapshot<Map<String, dynamic>>? cursor,
    int limit = 20,
  }) => serviceCall(() async {
    client.uid;
    if (limit < 1 || limit > 100) {
      throw const ServiceException(
        'invalid-argument',
        'La limite doit être entre 1 et 100.',
      );
    }
    Query<Map<String, dynamic>> query = client.firestore.collection('items');
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    query = query.orderBy('name').orderBy(FieldPath.documentId);
    if (cursor != null) query = query.startAfterDocument(cursor);
    final result = await query.limit(limit + 1).get();
    final docs = result.docs.take(limit).toList();
    return ItemPage(
      items: docs
          .map((doc) => ModelCodec.item({...doc.data(), 'id': doc.id}))
          .toList(),
      nextCursor: result.docs.length > limit ? docs.last : null,
    );
  });

  Future<void> delete(String id) => serviceCall(() async {
    await client.call('items.delete', {'id': id});
  });
}
