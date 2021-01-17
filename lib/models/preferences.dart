import 'package:flutter/material.dart';

class Tag {
  String displayName;
  String databaseValue;
  String category;
  bool selected;

  Tag(
      {this.displayName,
      this.databaseValue,
      this.category,
      this.selected = false});

  Tag.fromTag(Tag originalTag)
      : displayName = originalTag.displayName,
        databaseValue = originalTag.databaseValue,
        category = originalTag.category,
        selected = originalTag.selected;
}

final List<Tag> originalTags = [
  Tag(
      displayName: 'Easy paid work e.g. flyering',
      databaseValue: 'Easy paid',
      category: 'type'),
  Tag(
    displayName: 'Career Experience',
    databaseValue: 'Career Experience',
    category: 'type',
  ),
  Tag(
    displayName: 'Skilled paid work e.g. product design',
    databaseValue: 'Skilled paid',
    category: 'type',
  ),
  Tag(
    displayName: 'Interesting Projects',
    databaseValue: 'Projects',
    category: 'type',
  ),
  Tag(
    displayName: 'Academic Research',
    databaseValue: 'Research',
    category: 'type',
  ),
  Tag(
    displayName: 'Scholarships / Awards',
    databaseValue: 'Awards',
    category: 'type',
  ),
  Tag(
    displayName: 'STEM',
    databaseValue: 'STEM',
    category: 'area',
  ),
  Tag(
    displayName: 'Public Sector',
    databaseValue: 'Public Sector',
    category: 'area',
  ),
  Tag(
    displayName: 'Social Impact',
    databaseValue: 'Social Impact',
    category: 'area',
  ),
  Tag(
    displayName: 'Arts / Creative',
    databaseValue: 'Arts / Creative',
    category: 'area',
  ),
  Tag(
    displayName: 'Sustainability',
    databaseValue: 'Sustainability',
    category: 'area',
  ),
  Tag(
    displayName: 'Banking / Law / Consulting',
    databaseValue: 'Banking / Law / Consulting',
    category: 'area',
  ),
  Tag(
    displayName: 'Journalism',
    databaseValue: 'Journalism',
    category: 'area',
  ),
  Tag(
    displayName: 'Short term (within a week/a few days)',
    databaseValue: 'Short term',
    category: 'spec',
  ),
  Tag(
    displayName: 'With companies',
    databaseValue: 'Companies',
    category: 'spec',
  ),
  Tag(
    displayName: 'Long term (over several weeks)',
    databaseValue: 'Long term',
    category: 'spec',
  ),
  Tag(
    displayName: 'With student groups',
    databaseValue: 'Student groups',
    category: 'spec',
  ),
  Tag(
    displayName: 'During term time',
    databaseValue: 'During term',
    category: 'spec',
  ),
  Tag(
    displayName: 'Outside of term time',
    databaseValue: 'Outside of term',
    category: 'spec',
  ),
  Tag(
    displayName: 'With charities',
    databaseValue: 'Charities',
    category: 'spec',
  ),
];
