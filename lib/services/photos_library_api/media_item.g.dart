/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) {
  // print('<--- json');
  // print(json);
  return MediaItem(
    id: json['id'] as String,
    description: json['description'] as String,
    productUrl: json['productUrl'] as String,
    baseUrl: json['baseUrl'] as String,
    filename: json['filename'] as String,
    mimeType: json['mimeType'] as String,
    height: int.parse(json['mediaMetadata']['height']),
    width: int.parse(json['mediaMetadata']['width'])
  );

}

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'productUrl': instance.productUrl,
      'baseUrl': instance.baseUrl
    };
