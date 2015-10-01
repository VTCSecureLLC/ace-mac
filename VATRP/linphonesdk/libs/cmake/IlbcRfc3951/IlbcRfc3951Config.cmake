############################################################################
# IlbcRfc3951Config.cmake
# Copyright (C) 2015  Belledonne Communications, Grenoble France
#
############################################################################
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
############################################################################
#
# Config file for the libilbcrfc3951 package.
# It defines the following variables:
#
#  ILBCRFC3951_FOUND - system has libilbcrfc3951
#  ILBCRFC3951_INCLUDE_DIRS - the libilbcrfc3951 include directory
#  ILBCRFC3951_LIBRARIES - The libraries needed to use libilbcrfc3951

include("${CMAKE_CURRENT_LIST_DIR}/IlbcRfc3951Targets.cmake")

get_filename_component(ILBCRFC3951_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
set(ILBCRFC3951_INCLUDE_DIRS "${ILBCRFC3951_CMAKE_DIR}/../../../include")
set(ILBCRFC3951_LIBRARIES BelledonneCommunications::ilbcrfc3951)
set(ILBCRFC3951_FOUND 1)
