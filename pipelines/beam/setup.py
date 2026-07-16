from setuptools import find_packages, setup


setup(
    name="flowops-beam",
    version="0.1.0",
    description="FlowOps Apache Beam streaming pipelines",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    python_requires=">=3.11,<3.13",
    install_requires=[],
)