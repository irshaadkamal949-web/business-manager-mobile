import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class BmDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<Widget>> rows;

  const BmDataTable({Key? key, required this.columns, required this.rows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Tok.card : Tok.cardLight,
        border: Border.all(color: isDark ? Tok.border : Tok.borderLight),
        borderRadius: BorderRadius.circular(Tok.radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(isDark ? Tok.card2 : Tok.card2Light),
          dataRowColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.selected)) {
              return Tok.goldBg;
            }
            return isDark ? Tok.card : Tok.cardLight;
          }),
          dividerThickness: 1,
          horizontalMargin: 12,
          columnSpacing: 20,
          headingTextStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDark ? Tok.text3 : Tok.text3Light,
            letterSpacing: 0.5,
          ),
          dataTextStyle: TextStyle(
            fontSize: 12,
            color: isDark ? Tok.text : Tok.textLight,
          ),
          border: TableBorder(
            horizontalInside: BorderSide(color: isDark ? Tok.border : Tok.borderLight),
          ),
          columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
          rows: rows.map((r) => DataRow(cells: r.map((c) => DataCell(c)).toList())).toList(),
        ),
      ),
    );
  }
}
