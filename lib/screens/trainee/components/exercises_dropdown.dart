import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ExercisesDropdown extends StatefulWidget {
  final TextEditingController? dropdownSearchController;
  final Function(int) onChangeCallback;
  final List<int> disabledItems;

  const ExercisesDropdown({Key? key, this.dropdownSearchController, required this.onChangeCallback, required this.disabledItems})
      : super(key: key);

  @override
  State<ExercisesDropdown> createState() => _ExercisesDropdownState();
}

class _ExercisesDropdownState extends State<ExercisesDropdown> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.dropdownSearchController ?? TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ExercisesProvider>(context, listen: false).fetchExercises().then((value) {
        // widget.onChangeCallback(context.read<ExercisesProvider>().list.first.id);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ExercisesProvider>(
      builder: (context, provider, child) {
        return provider.isLoading ? Container(height: 50, child: const Center(child: CircularProgressIndicator()),) : DropdownSearch<Exercise>(
          mode: Mode.MENU,
          showSearchBox: true,
          items: context.watch<ExercisesProvider>().list,
          itemAsString: (Exercise? item) => item?.name ?? '',
          popupItemDisabled: (Exercise? item) => widget.disabledItems.contains(item?.id),
          onChanged: (Exercise? item) {
            widget.onChangeCallback(item?.id ?? 0);
          },
          selectedItem: null,
          popupItemBuilder: (BuildContext context, Exercise? item, bool isSelected,) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: !isSelected
                  ? null
                  : BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: ListTile(
                selected: isSelected,
                title: Text(item?.name ?? ''),
              ),
            );
          },
          searchFieldProps: TextFieldProps(
            controller: controller,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                },
              ),
            ),
          ),

        );
      }
    );
  }
}