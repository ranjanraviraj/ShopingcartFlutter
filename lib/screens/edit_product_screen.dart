import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';
import '../const/constant.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlTextControler = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var isInit = true;
  var isLoading = false;
  var _editedValue = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValue = {
    Constant.TITLE: '',
    Constant.DESCRIPTION: '',
    Constant.PRICE: '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final product = Provider.of<Products>(context).findById(productId);
        _editedValue = product;
        _initValue = {
          Constant.TITLE: _editedValue.title,
          Constant.DESCRIPTION: _editedValue.description,
          Constant.PRICE: _editedValue.price.toString(),
        };
        _imageUrlTextControler.text = _editedValue.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlTextControler.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlTextControler.text.startsWith('http') &&
              !_imageUrlTextControler.text.startsWith('https')) ||
          (!_imageUrlTextControler.text.endsWith('.png') &&
              !_imageUrlTextControler.text.endsWith('.jpg') &&
              !_imageUrlTextControler.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {
        print('re run');
      });
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (_editedValue.id != null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(_editedValue.id, _editedValue);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text('Something went wrong!'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ));
      } 
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedValue);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text('Something went wrong!'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Okay'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ));
      } 
    }
    setState(() {
          isLoading = true;
        });
        Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValue[Constant.TITLE],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _editedValue = Product(
                            id: _editedValue.id,
                            title: value,
                            description: _editedValue.description,
                            price: _editedValue.price,
                            imageUrl: _editedValue.imageUrl,
                            isFavorite: _editedValue.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Title is required!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue[Constant.PRICE],
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _editedValue = Product(
                            id: _editedValue.id,
                            title: _editedValue.title,
                            description: _editedValue.description,
                            price: double.parse(value),
                            imageUrl: _editedValue.imageUrl,
                            isFavorite: _editedValue.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Price is required!';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid number!';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than zero!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue[Constant.DESCRIPTION],
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (value) {
                          _editedValue = Product(
                            id: _editedValue.id,
                            title: _editedValue.title,
                            description: value,
                            price: _editedValue.price,
                            imageUrl: _editedValue.imageUrl,
                            isFavorite: _editedValue.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Description is required!';
                          }
                          if (value.length < 10) {
                            return 'Please enter atleast 10 chanrater for description!';
                          }
                          return null;
                        },
                        // onFieldSubmitted: (_){
                        //   FocusScope.of(context).requestFocus(_priceFocusNode);
                        // },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            padding: EdgeInsets.all(3),
                            margin: const EdgeInsets.only(top: 14, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageUrlTextControler.text.isEmpty
                                ? Text(
                                    'Enter image Url',
                                    softWrap: true,
                                  )
                                : FittedBox(
                                    child: Image.network(
                                        _imageUrlTextControler.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Imgae URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlTextControler,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (value) {
                                _editedValue = Product(
                                  id: _editedValue.id,
                                  title: _editedValue.title,
                                  description: _editedValue.description,
                                  price: _editedValue.price,
                                  imageUrl: value,
                                  isFavorite: _editedValue.isFavorite,
                                );
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Valid Image URL is required!';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter valid url';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Please enter valid image url';
                                }
                                return null;
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
