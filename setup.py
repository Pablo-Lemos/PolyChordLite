from setuptools import setup, Extension
import os
import numpy


def readme():
    with open('pypolychord_README.rst') as f:
        return f.read()


def get_version(short=False):
    with open('pypolychord/src/polychord/feedback.f90') as f:
        for line in f:
            if 'version' in line:
                return line[44:48]


pypolychord_module = Extension(
        name='_pypolychord',
        library_dirs=[os.path.join(os.getcwd(), 'pypolychord/lib')],
        include_dirs=[os.path.join(os.getcwd(), 'pypolychord/src/polychord/'),
                      numpy.get_include()],
        runtime_library_dirs=[os.path.join(os.getcwd(), 'pypolychord/lib')],
        libraries=['pypolychord/chord'],
        sources=[os.path.join(os.getcwd(),
                 'pypolychord/_pypolychord.cpp')]
        )

setup(name='pypolychord',
      version=get_version(),
      description='Python interface to PolyChord ' + get_version(),
      url='https://ccpforge.cse.rl.ac.uk/gf/project/polychord/',
      author='Will Handley',
      author_email='wh260@cam.ac.uk',
      license='PolyChord',
      packages=['pypolychord'],
      install_requires=['numpy'],
      extras_require={'plotting': 'getdist'},
      ext_modules=[pypolychord_module],
      zip_safe=False)
