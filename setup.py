from setuptools import setup

# def readme():
# with open('README.md') as f:
# return f.read()

# We're getting the version from a file
__version__ = "0.0.0"
# exec(open('/usr/src/pteryx/pteryx/version.py').read())

setup(
    name="pteryx",
    description="a panoply of assemblies",
    packages=["pteryx"],
    install_requires=["snakemake", "biopython", "build"],
    dependency_links=["http://pypi.ginkgobioworks.com/simple"],
    entry_points={"console_scripts": ["pteryx = pteryx.run:entrypoint"]},
    include_package_data=True,
    zip_safe=True,
    python_requires=">=3.6",
)
