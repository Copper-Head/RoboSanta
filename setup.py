from setuptools import setup

setup(
    name='robosanta',
    py_modules=['robosanta'],
    install_requires=[
        'click>=6.7',
        'six>=1.10',
    ],
    entry_points='''
        [console_scripts]
        robosanta=robosanta:cli
    ''',
)
