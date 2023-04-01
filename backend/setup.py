"""PIP installer for csce3513_project"""

from setuptools import setup, find_packages


def readme():
    """Get long description from README.md"""
    with open('README.md') as f:
        return f.read()


setup(
    name="CSCE 3513 Project",
    version="0.1.0",
    author="Luke Simmons",
    author_email="luke5083@live.com",
    description="Hackathon Spring 2023 backend server.",
    long_description=readme(),
    long_description_content_type="text/markdown",
    url="https://github.com/Skyluker4/HackathonSpring2023",
    packages=find_packages(),
    classifiers=[
        'Development Status :: 1 - Planning',
        "Programming Language :: Python :: 3 :: Only",
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: Microsoft :: Windows',
        'Operating System :: POSIX :: Linux',
        'Environment :: GUI',
        'Intended Audience :: Education',
        'Natural Language :: English',
        'Topic :: Education',
    ],
    python_requires='>=3.9',
    platforms=[
        'Linux',
        'MacOS X',
        'Windows'
    ],
    license='GNU Affero General Public License v3 (AGPLv3)'
)
