from fileIO import experiment_item_name

def test_experiment_item_name():
    path = "some-file.lp"
    assert experiment_item_name(path) == "some-file"

    nested_path = "/some-dir/some-file.lp"
    assert experiment_item_name(nested_path) == "some-file"

    different_extension = "some-file.txt"
    assert experiment_item_name(different_extension) == "some-file"

    many_extensions = "some-file.txt.lp"
    assert experiment_item_name(many_extensions) == "some-file.txt"

    hidden_path = "/some-dir/.hidden"
    assert experiment_item_name(hidden_path) == ".hidden"

    empty_path = ""
    assert experiment_item_name(empty_path) == ""
